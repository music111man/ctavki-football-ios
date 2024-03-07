//
//  PurchesVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

final class PurchesVController: FeaureVController {
    override func titleName() -> String {
        R.string.localizable.screen_paid_title()
    }
    override func icon() -> UIImage? {
        R.image.pay()
    }
}
