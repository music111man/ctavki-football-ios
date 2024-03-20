//
//  PurchesFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class PurchesFactory: VCFactory {
   
    private lazy var controller: PurchesVController = {
        PurchesVController()
    }()
    override func create() -> UIViewController {
        controller
    }
   
}
