//
//  FaqFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class FaqFactory: VCFactory {
    
    private lazy var controller: FaqVController = {
        FaqVController()
    }()
    
    override init() {
        super.init()
        self.controller.initFaqViews()
    }
    
    override func create() -> UIViewController {
       controller
    }
    
}

