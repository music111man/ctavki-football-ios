//
//  AppUpdateAvailable.swift
//  App
//
//  Created by Denis Shkultetskyy on 29.02.2024.
//

import Foundation

enum AppUpdateAvailable: String, Decodable {
    case none = ""
    case optional = "optional"
    case required = "required"
}
