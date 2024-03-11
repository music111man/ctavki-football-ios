//
//  TeamsRowView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsRowView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: BetViewDelegate?
}

extension TeamsRowView: BetViewDelegate {
    func openTeamDetails(team: Team, onLeft: Bool) {
        delegate?.openTeamDetails(team: team, onLeft: onLeft)
    }
}
