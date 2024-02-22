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
    
    private let action: Action
    private var buttons = [MenuButton]()
    
    init(action: @escaping Action) {
        self.action = action
        super.init(frame: CGRect())
        clipsToBounds = true
        buttons.append(contentsOf: [ MenuButton(title: R.string.localizable.picks(), icon: R.image.bets()) {[weak self] in
                                            self?.buttons.forEach { $0.isSelected = false }
                                            self?.buttons[0].isSelected = true
                                            self?.action(.bets)
                                        },
                                     MenuButton(title: R.string.localizable.teams_cap(), icon: R.image.teams()) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[1].isSelected = true
                                                                         self?.action(.teams)
                                                                     },
                                     MenuButton(title: R.string.localizable.paid_cap(), icon: R.image.pay()) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[2].isSelected = true
                                                                         self?.action(.pay)
                                                                     },
                                     MenuButton(title: R.string.localizable.questions(), icon: R.image.faq()) {[weak self] in
                                                                         self?.buttons.forEach { $0.isSelected = false }
                                                                         self?.buttons[3].isSelected = true
                                                                         self?.action(.faq)
                                                                     }
                                   ])
        buttons.forEach { btn in
            addSubview(btn)
            btn.initUI(isSelected: false)
        }
        buttons.first?.isSelected = true
                            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func addSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let anchor = subviews.last?.trailingAnchor ?? leadingAnchor
        super.addSubview(view)
        view.leadingAnchor.constraint(equalTo: anchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        if subviews.count == 4 {
            view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            
            return
        }
        view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25).isActive = true
    }
    
}
