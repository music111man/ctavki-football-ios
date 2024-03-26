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

enum SignInMethod {
    case google(idToken: String)
    case telegram(uuid: String)
    case apple(idToken: String, userName: String)
    case non
    
    var toString: String? {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .telegram: return "Telegram"
        default: return nil
        }
    }
}

final class AccountService: NSObject {
    
    static let share = AccountService()
    
    private override init(){}
    
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
                AppSettings.signInMethod = .google(idToken: idToken)
                self?.signIn()
            }
        }
    }
    
    func signInByTelegram() {
        let uuid = UUID().uuidString
        let url = AppSettings.telegramBotUrl(uuid)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                if success {
                    printAppEvent("will sing in by telegram with uuid: \(uuid)")
                    AppSettings.signInMethod = .telegram(uuid: uuid)
                }
            })
        }
        
    }
    
    @discardableResult
    func signIn() -> Bool {
        switch AppSettings.signInMethod {
        case .non:
            return false
        case let .telegram(uuid):
            singInTelegram(uuid)
            return true
        case let .google(idToken):
            singInGoogle(idToken)
            return true
        case .apple(let idToken, let userName):
            singInApple(idToken, userName)
            return true
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
    
    private func singInApple(_ idToken: String, _ userName: String) {
        printAppEvent("start sign in apple")
        NetProvider.makeRequest(SignInResponseEntity.self, .signInByApple(idToken: idToken, userName: userName)) {[weak self] response in
            self?.processResponse(response: response)
        }
    }
    
    private func processResponse(response: SignInResponseEntity?) {
        defer {
            printAppEvent("reset sing in method to non")
            AppSettings.signInMethod = .non }
        guard let response = response else {
            printAppEvent("bad sign in response")
            return
        }
        
        if response.code != 200 {
            printAppEvent("sign in error: code \(response.code) msg: \(response.msg)")
            NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
            AppSettings.authorizeEvent.accept(false)
            return
        }
        
        let account = Account(id: response.userId,
                              email: response.email,
                              name: response.name,
                              betsLeft: response.betsLeft,
                              alreadyRegistered: response.alreadyRegistered,
                              subscribed: response.subscribed)
        Repository.refreshData([account])
        AppSettings.userName = response.name
        AppSettings.userToken = response.jwt
        
        return
    }
}

@available(iOS 13.0, *)
extension AccountService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.authorizationCode,
              let token = String(data: tokenData, encoding: .utf8) else { return }

        let userName = "\(credential.fullName?.givenName ?? "") \(credential.fullName?.familyName ?? "")"
        printAppEvent("apple sign in for \(userName)")
        AppSettings.signInMethod = .apple(idToken: token, userName: userName)
        signIn()
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        printAppEvent("\(error)")
    }
}
