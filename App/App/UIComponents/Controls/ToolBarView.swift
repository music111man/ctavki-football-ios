//
//  ToolBarView.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import UIKit

final class ToolBarView: UIView {
    enum MenuAction {
        case bets
        case teams
        case pay
        case faq
    }
    typealias Action = (_ action: MenuAction) -> ()
    
    var action: Action!
    private var buttons = [MenuButton]()
    private let borderTopView = UIView()
    func initUI(action: @escaping Action) {
        self.action = action
        clipsToBounds = false
        buttons.append(contentsOf: [ MenuButton(title: R.string.localizable.picks(), icon: R.image.bets(), true) {[weak self] in
                                                                        self?.buttons.forEach { $0.isSelected = false }
                                                                        self?.buttons[0].isSelected = true
                                                                        self?.action(.bets)
                                                                    },
                                     MenuButton(title: R.string.localizable.teams_cap(), icon: R.image.teams(), false) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[1].isSelected = true
                                                                         self?.action(.teams)
                                                                     },
                                     MenuButton(title: R.string.localizable.paid_cap(), icon: R.image.pay(), false) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[2].isSelected = true
                                                                         self?.action(.pay)
                                                                     },
                                     MenuButton(title: R.string.localizable.questions(), icon: R.image.faq(), false) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[3].isSelected = true
                                                                         self?.action(.faq)
                                                                     }
                                   ])
        addSubview(borderTopView)
        buttons.forEach { btn in
            addButtons(btn)
        }
        borderTopView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            borderTopView.topAnchor.constraint(equalTo: topAnchor),
            borderTopView.leftAnchor.constraint(equalTo: leftAnchor),
            borderTopView.rightAnchor.constraint(equalTo: rightAnchor),
            borderTopView.heightAnchor.constraint(equalToConstant: 1),
        ])
        borderTopView.backgroundColor = R.color.toolbarItem()?.withAlphaComponent(0.5)
        backgroundColor = .backgroundLightTheme
    }
    
    func selectMenuBtn(_ action: MenuAction) {
        buttons.forEach { $0.isSelected = false }
        switch action {
        case .bets:
            buttons[0].isSelected = true
        case .teams:
            buttons[1].isSelected = true
        case .pay:
            buttons[2].isSelected = true
        case .faq:
            buttons[3].isSelected = true
        }
    }
    
    private func addButtons(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let anchor = subviews.count > 1 ? subviews.last!.trailingAnchor : leadingAnchor
        super.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: anchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        if subviews.count == 5 {
            view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            
            return
        }
        view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25).isActive = true
    }
    
}
