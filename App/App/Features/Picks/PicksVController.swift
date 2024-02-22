//
//  PicksVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import UIKit

class PicksVController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        let label = UILabel()
        view.backgroundColor = UIColor.white
        label.text = labelName()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    func labelName() -> String {
        R.string.localizable.tooltip_bets_title()
    }
}
