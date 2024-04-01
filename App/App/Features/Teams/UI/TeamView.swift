//
//  TeamView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit
import RxSwift


class TeamView: UIView {

    let label = UILabel()

    let padding: CGFloat = 10
    let height: CGFloat = 46
    let disposeBag = DisposeBag()
    var team: TeamViewModel!
    
    func config(team: TeamViewModel) -> TeamView {
        self.team = team
        label.text = team.toString
        label.textColor = .textBlack
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding),
            heightAnchor.constraint(equalToConstant: height)
        ])
        backgroundColor = .backgroundLight
        roundCorners(radius: 6)
        setshadow()
        tap { [weak self] in
            guard let self = self else { return }
            delegate?.openTeamDetails(teamId: self.team.team.id, onLeft: true)
        }.disposed(by: disposeBag)
        
        return self
    }
   
    weak var delegate: BetViewDelegate?
    
    var minWidth: CGFloat {
        label.intrinsicContentSize.width + padding * 2
    }
}
