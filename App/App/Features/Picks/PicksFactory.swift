//
//  PicksFactory.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

final class PicksFactory: VCFactory {
    let controller = PicksVController().initBetViews()
    override func create() -> UIViewController {
        return controller
    }
}
