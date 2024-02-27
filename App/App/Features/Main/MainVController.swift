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

    var delegate: MainViewDelegate?
    private let toolBar = ToolBarView()
    private let containerView = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        view.backgroundColor = R.color.background_main()
        toolBar.initUI { [weak self] action in
            self?.delegate?.pushView(action)
        }

        toolBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        view.addSubview(toolBar)
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        let bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        let margin = 0.0
        NSLayoutConstraint.activate([
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomSafeAreaHeight),
            toolBar.heightAnchor.constraint(equalToConstant: 58),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])
    }

    func add(vc: UIViewController) {
        if let childVC = self.children.first {
            childVC.didMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        addChild(vc)
        vc.view.backgroundColor = UIColor.clear
        containerView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        vc.didMove(toParent: self)
    }

    func setChildVC(vc: UIViewController,_ complite: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.containerView.layer.opacity = 0
        }, completion: {[weak self] _ in
            self?.add(vc: vc)
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.containerView.layer.opacity = 1
            }, completion: { _ in
                complite?()
            })
        })
    }
    
}
