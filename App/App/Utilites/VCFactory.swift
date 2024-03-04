//
//  PVCFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

protocol PVCFactory {
    func create() -> UIViewController
    func clear()
}

class VCFactory: PVCFactory {
    
    private var navigator: UINavigationController?
    
    func create() -> UIViewController {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clear() {
        if let isEmpty = navigator?.viewControllers.isEmpty, isEmpty {
            navigator = nil
        }
    }
    
    func getNavigator() -> UINavigationController {
        guard let navigator = self.navigator else {
            let navigator = UINavigationController()
            navigator.isNavigationBarHidden = true
            self.navigator = navigator
            
            return navigator
        }
        
        return navigator
    }
    
}
