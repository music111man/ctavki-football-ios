//
//  AccountService.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import Foundation
import UIKit
import GoogleSignIn
import AuthenticationServices

enum SignMethod {
    case google(idToken: String)
    case telegram(uuid: String)
    case apple(idToken: String, userName: String, userEmail: String)
    case singOutFromApple
    case non
    
    var toString: String? {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .telegram: return "Telegram"
        case .singOutFromApple: return "Apple"
        default: return nil
        }
    }
}

protocol AccountServiceDelegate: AnyObject {
    func showNameWarning()
    func showEmailWarning()
}

final class AccountService: NSObject {
    
    static let share = AccountService()
    
    private override init(){}
    
    weak var delegate: AccountServiceDelegate?
    
    @available(iOS 13.0, *)
    func signInByApple(presenting vc: ASAuthorizationControllerPresentationContextProviding) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = vc
        authorizationController.performRequests()
    }
    
    func signInByGoogle(presenting vc: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
            if let error = error {
            printAppEvent("\(error)")
                return
            }
            guard let signInResult = signInResult else { return }

            signInResult.user.refreshTokensIfNeeded {[weak self] user, error in
                guard error == nil else { return }
                guard let user = user, let idToken = user.idToken?.tokenString else { return }
                AppSettings.signMethod = .google(idToken: idToken)
                self?.signAction()
            }
        }
    }
    
    func canSignInByTelegram() -> Bool {
        guard let url = URL(string: "tg://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func signInByTelegram() {
        let uuid = UUID().uuidString
        let url = AppSettings.telegramBotUrl(uuid)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                if success {
                    printAppEvent("will sing in by telegram with uuid: \(uuid)")
                    AppSettings.signMethod = .telegram(uuid: uuid)
                }
            })
        }
    }
    
    @discardableResult
    func signAction() -> Bool {
        switch AppSettings.signMethod {
        case .non:
            return false
        case let .telegram(uuid):
            singInTelegram(uuid)
            return true
        case let .google(idToken):
            singInGoogle(idToken)
            return true
        case .apple(let idToken, let userName, let userEmail):
            singInApple(idToken, userName, userEmail)
            return true
        case .singOutFromApple:
            singOutApple()
            return true
        }
    }
    
    private func singOutApple() {
        printAppEvent("start sign out from apple")
        DispatchQueue.global().async {
            NetProvider.makeRequest(SignOutResponseEntity.self, .signOutFromApple) {response in
                defer {
                    printAppEvent("reset sing out method to non")
                    AppSettings.signMethod = .non
                }
                guard let code = response?.code, code == 200 else {
                    printAppEvent("sign out error: code \(response?.code ?? 0) msg: \(response?.msg ?? "unknown error")")
                    NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
                    AppSettings.authorizeEvent.accept(true)
                    return
                }
                AppSettings.enableSignOut = false
                AppSettings.userName = ""
                AppSettings.userToken = ""
                
            }
        }
    }
    
    private func singInTelegram(_ uuid: String) {
        printAppEvent("start sign in telegram")
        DispatchQueue.global().async {
            NetProvider.makeRequest(SignInResponseEntity.self, .signInByTelegram(uuid: uuid)) {[weak self] response in
                self?.processResponse(response: response)
            }
        }
    }
    
    private func singInGoogle(_ idToken: String) {
        printAppEvent("start sign in google")
        NetProvider.makeRequest(SignInResponseEntity.self, .signInByGoogle(idToken: idToken)) {[weak self] response in
            self?.processResponse(response: response)
        }
    }
    
    private func singInApple(_ idToken: String, _ userName: String, _ userEmail: String) {
//        if userName.isEmpty {
//            delegate?.showNameWarning()
//            AppSettings.signMethod = .non
//            printAppEvent("can not start sign in apple - no user name")
//            
//            return
//        }
//        if userEmail.isEmpty {
//            delegate?.showEmailWarning()
//            AppSettings.signMethod = .non
//            printAppEvent("can not start sign in apple - fake email")
//            
//            return
//        }
        
        printAppEvent("start sign in apple as \(userName) with \(userEmail)")
        NetProvider.makeRequest(SignInResponseEntity.self, .signInByApple(idToken: idToken, userName: userName, userEmail: userEmail)) {[weak self] response in
            self?.processResponse(response: response, enableSingOut: true)
        }
    }
    
    private func processResponse(response: SignInResponseEntity?, enableSingOut: Bool = false) {
        defer {
            printAppEvent("reset sing in method to non")
            AppSettings.signMethod = .non }
        guard let response = response else {
            printAppEvent("bad sign in response")
            
            return
        }
        
        guard response.code == 200,
              let userIdStr = response.userId,
              let userId = Int(userIdStr),
              let email = response.email,
              let name = response.name,
              let betsLeftStr = response.betsLeft,
              let betsLeft = Int(betsLeftStr),
              let alreadyRegistered = response.alreadyRegistered,
              let jwt = response.jwt else {
            printAppEvent("sign in error: code \(response.code) msg: \(response.msg)")
            NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
            AppSettings.authorizeEvent.accept(false)
            return
        }
        
        let account = Account(id: userId,
                              email: email,
                              name: name,
                              betsLeft: betsLeft,
                              alreadyRegistered: alreadyRegistered,
                              subscribed: response.subscribed)
        Repository.refreshData([account])
        AppSettings.enableSignOut = enableSingOut
        AppSettings.userName = name
        AppSettings.userToken = jwt

        return
    }
}

@available(iOS 13.0, *)
extension AccountService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.authorizationCode,
              let token = String(data: tokenData, encoding: .utf8),
              let identityTokenData = credential.identityToken else { return }

        var userName = ""
        if let givenName = credential.fullName?.givenName, !givenName.isEmpty {
            userName = givenName
        }
        if let familyName = credential.fullName?.familyName, !familyName.isEmpty {
            if userName.isEmpty {
                userName = familyName
            } else {
                userName = "\(userName) \(familyName)"
            }
        }
        let userEmail = credential.email ?? ""
//        if let email = credential.email, !email.lowercased().contains("@privaterelay.appleid.com") {
//            userEmail = email
//        }
        printAppEvent("apple user: \(userName) and email: \(credential.email ?? "none")")
        AppSettings.signMethod = .apple(idToken: token, userName: userName, userEmail: userEmail)
        signAction()

    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        printAppEvent("\(error)")
    }
}
