//
//  FaqVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

final class FaqVController: FeaureVController {
    override func titleName() -> String {
        R.string.localizable.screen_faq_title()
    }
    
    override func icon() -> UIImage? {
        R.image.faq()
    }
}
