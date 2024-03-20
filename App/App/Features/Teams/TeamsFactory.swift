//
//  TeamsFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class TeamsFactory: VCFactory {
    let controller = TeamsVController()
    override init() {
        controller.initTeamViews()
    }
    
    override func create() -> UIViewController {
        let navigator = getNavigator()
        if navigator.viewControllers.isEmpty {
            navigator.pushViewController(controller, animated: false)
        }
        
        return navigator
    }
}
