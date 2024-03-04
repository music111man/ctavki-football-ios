//
//  ActualBetCell.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit

class ActualBetCell: UITableViewCell {
    
    static let reuseIdentifier = "ActualBetCell"
    
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var goustTeamNameLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var teamsView: UIView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        teamsView.backgroundColor = R.color.background_light()
        resultView.setGradient(start: R.color.viotet_start()!, end: R.color.violet_end()!, isLine: false)
        homeTeamNameLabel.font = UIFont.systemFont(ofSize: 16)
        goustTeamNameLabel.font = UIFont.systemFont(ofSize: 16)
        homeTeamNameLabel.textColor = R.color.text()
        goustTeamNameLabel.textColor = R.color.text()
        homeTeamNameLabel.textAlignment = .center
        goustTeamNameLabel.textAlignment = .center
        goustTeamNameLabel.font = UIFont.systemFont(ofSize: 16)
        resultLabel.textColor = R.color.title_color()
        resultLabel.textAlignment = .center
        teamsView.roundCorners(radius: 10)
        teamsView.setshadow()
        resultView.roundCorners()
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        teamsView.roundCorners(radius: 10)
        resultView.roundCorners()
    }
}
