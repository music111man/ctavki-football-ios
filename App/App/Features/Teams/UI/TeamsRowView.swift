//
//  TeamsRowView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsRowView: UIView {

    let stackView = UIStackView()
    weak var delegate: BetViewDelegate?
    
    func configure(teams: [TeamViewModel]) -> [TeamViewModel] {
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        var unusedTeams = [TeamViewModel]()
        var width: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width
        for team in teams {
            let view = TeamView().config(team: team)
            width += view.minWidth + 20
            if width >= screenWidth {
                unusedTeams.append(team)
                continue
            }
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
        
        if stackView.arrangedSubviews.count > 1 {
            stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        return unusedTeams
    }
}

extension TeamsRowView: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        delegate?.openTeamDetails(teamId: teamId, onLeft: onLeft)
    }
}
