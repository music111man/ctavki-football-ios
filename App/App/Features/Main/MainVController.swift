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
    private let backView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        view.backgroundColor = R.color.background_main_light()
        toolBar.initUI { [weak self] action in
            self?.delegate?.pushView(action)
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

    func setChildVC(vc: UIViewController, flipFromRight: Bool? = nil,_ complite: (() -> Void)? = nil) {
        guard let flipFromRight = flipFromRight else {
            self.containerView.transform =  .init(scaleX: 0.01, y: 0.01)
            self.containerView.layer.opacity = 0
            self.add(vc: vc)
            UIView.animate(withDuration: 0.4, animations: {[weak self] in
                guard let self = self else { return }
                self.containerView.transform = .identity
                self.containerView.layer.opacity = 1
            }, completion: { _ in
                complite?()
            })

            return
        }
        UIView.transition(with: containerView,
                          duration: 0.5,
                          options: [flipFromRight ? .transitionFlipFromRight : .transitionFlipFromLeft],
                          animations: { [weak self] in
            self?.add(vc: vc)
        }) { _ in
            complite?()
        }
    }
    
    func animate(onLeft: Bool? = nil, _ complite: @escaping() -> ()) {
        if let onLeft = onLeft {
            UIView.transition(with: backView,
                              duration: 0.4,
                              options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
                              animations: {[weak self] in
                self?.backView.layer.opacity = 0
                
            }) {[weak self] _ in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) { [weak self] in
                    self?.backView.layer.opacity = 1
                }
                complite()
            }
            
            return
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.containerView.transform = .init(scaleX: 0.01, y: 0.01)
            self?.toolBar.layer.opacity = 0
        } completion: { [weak self] _ in
            self?.containerView.transform = .identity
            self?.toolBar.layer.opacity = 1
            complite()
        }
    }
    
}
