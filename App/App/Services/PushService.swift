//
//  PushManager.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 26.03.2024.
//

import Foundation
import UserNotifications
import FirebaseCore
import FirebaseMessaging

enum PushRedirect {
    case paid
    case faq
    case team(Int)
    case teams
    case url(String)
    case bet(Int)
    
    init?(_ value: String, id: String?, url: String?) {
        switch value {
        case Self.paid.rawValue:
            self = .paid
        case Self.faq.rawValue:
            self = .faq
        case Self.teams.rawValue:
            self = .teams
        case Self.team(0).rawValue:
            self = .team(Int(id ?? "") ?? 0)
        case Self.url("").rawValue:
            self = .url(url ?? "")
        case Self.bet(0).rawValue:
            self = .bet(Int(id ?? "") ?? 0)
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .paid: return "REDIR_TERMS"
        case .faq: return "REDIR_FAQ"
        case .team: return "REDIR_TAG"
        case .teams: return "REDIR_HISTORY"
        case .url: return "REDIR_URL"
        case .bet: return "REDIR_BET"
        }
    }
}

struct PushKeys {
    static let redirectTo = "redirect_to"
    static let redirectToTagId = "redirect_to_tag_id"
    static let redirectToUrl = "redirect_to_url"
}

protocol PushManagerDelegate: AnyObject {
    func canShow(pushRedirect: PushRedirect) -> Bool
    func openScreen(pushRedirect: PushRedirect?)
}

final class PushService: NSObject {
    private var delegate: PushManagerDelegate!
    
    static func config(_ application: UIApplication,_ delegate: PushManagerDelegate) {
        if FirebaseApp.app() == nil {
            fatalError("FirebaseApp.configure() must be call before!!!")
        }
        
        let manager = PushService()
        manager.delegate = delegate
        Messaging.messaging().delegate = manager
        
        UNUserNotificationCenter.current().delegate = manager
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
            guard error == nil else{
                printAppEvent(error!.localizedDescription)
                return
            }
        }
        application.registerForRemoteNotifications()
    }
}

extension PushService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let redirectStr = notification.request.content.userInfo[PushKeys.redirectTo] as? String,
              let redirect = PushRedirect(redirectStr,
                                          id: notification.request.content.userInfo[PushKeys.redirectToTagId] as? String,
                                          url: notification.request.content.userInfo[PushKeys.redirectToUrl] as? String) {
            if delegate.canShow(pushRedirect: redirect) {
                completionHandler([.alert, .sound, .badge])
            }
        }
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        UIApplication.shared.applicationIconBadgeNumber = 0
        guard let redirectStr = response.notification.request.content.userInfo[PushKeys.redirectTo] as? String,
              let redirect = PushRedirect(redirectStr,
                                          id: response.notification.request.content.userInfo[PushKeys.redirectToTagId] as? String,
                                          url: response.notification.request.content.userInfo[PushKeys.redirectToUrl] as? String) else {
            delegate.openScreen(pushRedirect: nil)
            return
        }
        
        
        delegate.openScreen(pushRedirect: redirect)
    }
}

extension PushService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppSettings.fcmToken = fcmToken ?? ""
        printAppEvent("fnc token: \(AppSettings.fcmToken)", marker: ">>pushServ ")
        if fcmToken == nil { return }
        
        let topicAll = "all"
        Messaging.messaging().subscribe(toTopic: topicAll) { error in
            if let error = error {
                printAppEvent("Subscribed to topic \"\(topicAll)\" with error: \(error.localizedDescription)", marker: ">>pushServ ")
            }
        }
    }
}
