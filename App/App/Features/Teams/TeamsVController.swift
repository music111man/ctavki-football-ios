//
//  TeamsVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

final class TeamsVController: FeaureVController {
    override func titleName() -> String {
        R.string.localizable.tooltip_teams_title()
    }
    override func icon() -> UIImage? {
        R.image.teams()
    }
}
