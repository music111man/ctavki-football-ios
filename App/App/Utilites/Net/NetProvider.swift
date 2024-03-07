//
//  NetProvider.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation
import Moya

extension Notification.Name {

    static let badNetRequest = Notification.Name("badNetRequest")
    static let deserializeError = Notification.Name("deserializeError")
}

class NetProvider {
    
    static func makeRequest<T: Decodable>(_ type: T.Type, _ target: ApiRequest,_ callback: ((T) -> Void)?)  {
        let provider = MoyaProvider<ApiRequest>()
        provider.request(target) { result in
            switch result {
            case .success(let response):
                guard let data = try? JSONDecoder().decode(type, from: response.data) else {
                    printAppEvent("\(target): can not deserialize to \(T.self)")
                    NotificationCenter.default.post(name: NSNotification.Name.deserializeError, object: target)
                    break
                }
                callback?(data)
            case .failure(let error):
                printAppEvent("\(target): \(error.errorDescription ?? "Unknown net error")")
                NotificationCenter.default.post(name: NSNotification.Name.badNetRequest, object: target)
            }
            
        }
    }
}


