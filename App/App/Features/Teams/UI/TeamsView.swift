//
//  TeamsView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsView: UIView {
    let headerLabel = UILabel()
    let separatorView = UIView()
    let stackView = UIStackView()
    weak var delegate: BetViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let g = separatorView.setGradient(colors: [.backgroundMain,
                                                   .betGroupHeader,
                                                   .backgroundMain], isLine: true)
        g.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 20, height: 1))
    }
    
    func configure(title: String, teams: [TeamViewModel]) -> TeamsView {
        headerLabel.text = title
        headerLabel.font = UIFont.systemFont(ofSize: 13)
        headerLabel.textColor = .betGroupHeader
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            headerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            separatorView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
            separatorView.leftAnchor.constraint(equalTo: headerLabel.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: headerLabel.rightAnchor),
            stackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5)
        ])
        let g = separatorView.setGradient(colors: [.backgroundMain,
                                                   .betGroupHeader,
                                                   .backgroundMain], isLine: true)
        g.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 20, height: 1))
        stackView.replaceArrangedSubviews ({
            var unusedTeams = teams
            var views = [TeamsRowView]()
            while !unusedTeams.isEmpty {
                let row = TeamsRowView()
                unusedTeams = row.configure(teams: unusedTeams)
                row.delegate = self
                views.append(row)
            }
            
            return views
        })
        
        return self
    }

}

extension TeamsView: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        delegate?.openTeamDetails(teamId: teamId, onLeft: onLeft)
    }
}
