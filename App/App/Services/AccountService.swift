//
//  AccountService.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import Foundation
import UIKit

enum SignInMethod {
    case google(idToken: String)
    case telegram(uuid: String)
    case non
}

final class AccountService {
    
    func signInByGoogle() {
        printAppEvent("try sing in by google")
    }
    
    func signInByTelegram() {
        let uuid = UUID().uuidString
        let url = AppSettings.telegramBotUrl(uuid)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                if success {
                    printAppEvent("try sing in by telegram with uuid: \(uuid)")
                    AppSettings.signInMethod = .telegram(uuid: uuid)
                }
            })
        }
        
    }
    
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
        }
    }
    
    private func singInTelegram(_ uuid: String) {
        printAppEvent("start sign in telegram")
        DispatchQueue.global(qos: .userInteractive).async {
            NetProvider.makeRequest(SignInResponseEntity.self, .signInByTelegram(uuid: uuid)) {[weak self] response in
                guard let self = self else { 
                    AppSettings.authorizeEvent.accept(false)
                    return
                }
                self.processResponse(response: response)
            }
        }
    }
    
    private func singInGoogle(_ idToken: String) {
        printAppEvent("start sign in google")
        NetProvider.makeRequest(SignInResponseEntity.self, .signInByGoogle(idToken: idToken)) {[weak self] response in
            guard let self = self else {
                AppSettings.authorizeEvent.accept(false)
                return
            }
            self.processResponse(response: response)
        }
    }
    
    private func processResponse(response: SignInResponseEntity) {
        if response.code != 200 {
            printAppEvent("sign in error: code \(response.code) msg: \(response.msg)")
            NotificationCenter.default.post(name: NSNotification.Name.badServerResponse, object: nil)
            AppSettings.authorizeEvent.accept(false)
            return
        }
        AppSettings.signInMethod = .non
        
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
