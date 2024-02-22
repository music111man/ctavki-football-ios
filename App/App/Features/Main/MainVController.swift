//
//  ViewController.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit

protocol MainViewDelegate {
    func pushView(_ action: ToolBarView.MenuAction)
}

final class MainVController: UIViewController {
    
//    @IBOutlet weak var pickImageView: UIImageView!
//    @IBOutlet weak var teamImageView: UIImageView!
//    @IBOutlet weak var bayImageView: UIImageView!
    
    var delegate: MainViewDelegate?
    private var toolBar: ToolBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        view.backgroundColor = UIColor.white
        toolBar = ToolBarView( action: { [weak self] action in
            self?.delegate?.pushView(action)
        })

        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17).isActive = true
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        let topSafeAreaHeight = safeFrame.minY
        let bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomSafeAreaHeight).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 58).isActive = true
    }

}

