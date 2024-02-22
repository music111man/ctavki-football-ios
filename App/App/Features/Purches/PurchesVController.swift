//
//  PurchesVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

final class PurchesVController: PicksVController {
    override func labelName() -> String {
        R.string.localizable.tooltip_paid_title()
    }
}
