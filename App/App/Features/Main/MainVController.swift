//
//  ViewController.swift
//  App
//
//  Created by Denis Shkultetskyy on 21.02.2024.
//

import UIKit
import RxSwift

extension Notification.Name {
    static let hideMainToolBar = Notification.Name("hideMainToolBar")
    static let showMainToolBar = Notification.Name("showMainToolBar")
}

protocol MainViewDelegate {
    func pushView(_ action: ToolBarView.MenuAction, needSelectMenu: Bool)
}

final class MainVController: UIViewController {

    var delegate: MainViewDelegate?
    private let toolBar = ToolBarView()
    private let containerView = UIView()
    private let backView = UIView()
    let disposeBag = DisposeBag()
    
    var currentController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        NotificationCenter.default.rx.notification(Notification.Name.hideMainToolBar).subscribe {[weak self] _ in
            self?.toolBar.animateOpacity(0.3, 0) {[weak self] in
                self?.toolBar.isHidden = true
            }
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.showMainToolBar).subscribe {[weak self] _ in
            self?.toolBar.isHidden = false
            self?.toolBar.animateOpacity(0.3, 1)
        }.disposed(by: disposeBag)
    }

    func initUI() {
        view.backgroundColor = R.color.background_main_light()
        toolBar.initUI { [weak self] action in
            self?.delegate?.pushView(action,needSelectMenu: false)
        }

        toolBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backView)
        backView.addSubview(containerView)
        backView.addSubview(toolBar)
        let margin = 0.0
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: view.topAnchor),
            backView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: margin),
            toolBar.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -margin),
            toolBar.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -UIView.safeAreaHeight),
            toolBar.heightAnchor.constraint(equalToConstant: 58),
            containerView.topAnchor.constraint(equalTo: backView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: toolBar.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: margin),
            containerView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -margin)
        ])
    }

    func add(vc: UIViewController) {
        if let childVC = self.children.first {
            childVC.didMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        addChild(vc)
        currentController = vc
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

    func setChildVC(vc: UIViewController, action: ToolBarView.MenuAction? = nil, _ complite: (() -> Void)? = nil) {
        if let action = action {
            toolBar.selectMenuBtn(action)
        }
        add(vc: vc)
        complite?()
    }
    
}
