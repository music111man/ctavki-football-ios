//
//  TeamsRowView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsRowView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    weak var delegate: BetViewDelegate?
    
    func configure(teams: [TeamViewModel]) -> [TeamViewModel] {
        var unusedTeams = [TeamViewModel]()
        var width: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width
        for team in teams {
            let view: TeamView = .fromNib() { v in
                v.team = team
            }
            width += view.minWidth + 20
            if width >= screenWidth {
                unusedTeams.append(team)
                continue
            }
            view.delegate = self
            stackView.addArrangedSubview(view)
        }
        if stackView.arrangedSubviews.count == 1 {
            rightConstraint.isActive = false
        }
        
        return unusedTeams
    }
}

extension TeamsRowView: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        delegate?.openTeamDetails(teamId: teamId, onLeft: onLeft)
    }
}
