//
//  FeaureVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit

class FeaureVController: UIViewController {
    
    let navigationBar = NavigationTopBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.background_main()
        initUI()
    }
   
    func initUI() {
        navigationBar.initUI(parent: view, title: titleName(), icon: icon(), nil)
    }
    
    func titleName() -> String {
        "Set name!!!"
    }
    
    func icon() -> UIImage? {
        nil
    }
}
