//
//  TableViewCell.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsViewCell: UITableViewCell {

    weak var view: TeamsView!
    weak var delegate: BetViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view = .fromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func configure(model: TeamsViewModel) {
        view.configure(title: model.title, teams: model.teams)
    }
}

extension TeamsViewCell: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        delegate?.openTeamDetails(teamId: teamId, onLeft: onLeft)
    }
}
