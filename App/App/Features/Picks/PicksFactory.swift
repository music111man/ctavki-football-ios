//
//  PicksFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class PicksFactory: VCFactory {
    
    override func create() -> UIViewController {
        let navigator = getNavigator()
        if navigator.viewControllers.isEmpty {
            navigator.pushViewController(PicksVController(), animated: false)
        }
        
        return navigator
    }
}
