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
    var team: TeamViewModel! {
        didSet {
            label.text = team.toString
        }
    }
    weak var delegate: BetViewDelegate?
    
    var minWidth: CGFloat {
        label.intrinsicContentSize.width + leftConstraint.constant + rigthConstraint.constant
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorners(radius: 6)
        setshadow()
        
        tap { [weak self] in
            guard let self = self else { return }
            delegate?.openTeamDetails(teamId: self.team.team.id, onLeft: true)
        }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

}
