//
//  NoActivebetsCell.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit

class NoActiveBetsCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = R.string.localizable.no_active_bets()
        subTitleLabel.text = R.string.localizable.soon_we_provide_bets()
    }
    
}
