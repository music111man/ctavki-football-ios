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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name.tryToRefreshData, object: nil)
    }

    func initUI() {
        navigationItem.title = "\(labelName()) \(navigationController?.viewControllers.count ?? 0)"
        let label = UILabel()
        view.backgroundColor = R.color.background_main()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        if navigationController != nil {
            
            label.text = "Click to test insize navigation"
            
            
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOn)))
        } else {
            label.text = labelName()
        }
    }
    
    @objc func tapOn() {
        guard let nav = navigationController else {
            print("No navigations")
            return }
        nav.pushViewController(createVC(), animated: true)
    }
    
    func createVC() -> UIViewController {
        PicksVController()
    }
    
    func labelName() -> String {
        R.string.localizable.tooltip_bets_title()
    }
}
