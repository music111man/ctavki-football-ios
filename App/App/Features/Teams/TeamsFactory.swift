//
//  TeamsFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class TeamsFactory: VCFactory {
    var controller = TeamsVController().initTeamsFeatures()
    
    override func create() -> UIViewController {
        controller
    }
}
