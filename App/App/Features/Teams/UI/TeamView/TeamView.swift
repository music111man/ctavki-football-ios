//
//  TeamView.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit
import RxSwift


class TeamView: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rigthConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    var team: Team!
    weak var delegate: BetViewDelegate?
    
    var minWidth: CGFloat {
        label.intrinsicContentSize.width + leftConstraint.constant + rigthConstraint.constant
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorners(radius: 6)
        setshadow()
        label.text = team.title
        tap { [weak self] in
            guard let self = self else { return }
            delegate?.openTeamDetails(team: self.team, onLeft: true)
        }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
