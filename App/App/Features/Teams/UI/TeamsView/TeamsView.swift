//
//  TeamsView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class TeamsView: UIView {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: BetViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let g = separatorView.setGradient(colors: [.backgroundMain,
                                                   .betGroupHeader,
                                                   .backgroundMain], isLine: true)
        g.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 20, height: 1))
    }
    
    func configure(title: String, teams: [TeamViewModel]) {
        headerLabel.text = title
        stackView.replaceArrangedSubviews ({
            var unusedTeams = teams
            var views = [TeamsRowView]()
            while !unusedTeams.isEmpty {
                let row: TeamsRowView = .fromNib { v in
                    unusedTeams = v.configure(teams: unusedTeams)
                }
//                row.transform = .init(scaleX: 0, y: 0)
                row.delegate = self
                views.append(row)
            }
            
            return views
        }) 
//        {[weak self] in
//            UIView.animate(withDuration: 0.3) { [weak self] in
//                self?.stackView.arrangedSubviews.forEach { $0.transform = .identity }
//            }
//        }
        
    }

}

extension TeamsView: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        delegate?.openTeamDetails(teamId: teamId, onLeft: onLeft)
    }
}
