//
//  TeamsView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit
import RxSwift

class TeamsView: UIView {

    @IBOutlet weak var stackView: NSLayoutConstraint!
    let disposeBeg = DisposeBag()
    weak var delegate: BetViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

extension TeamsView: BetViewDelegate {
    func openTeamDetails(team: Team, onLeft: Bool) {
        delegate?.openTeamDetails(team: team, onLeft: onLeft)
    }
}
