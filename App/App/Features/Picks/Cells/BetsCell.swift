//
//  ActualBetCell.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit

class BetsCell: UITableViewCell {
    
    static let reuseIdentifier = "BetsCell"
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.font = UIFont.systemFont(ofSize: 13)
        headerLabel.textColor = R.color.bet_group_header()
        separatorView.setGradient(colors: [.white, R.color.bet_group_header()!, .white], isLine: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorView.layer.sublayers?.first?.frame = separatorView.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ model: BetGroup) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        if model.eventDate > Date() {
            let secondsAtDay: TimeInterval = 60.0 * 60.0 * 24.0
            let nextDate = Date().addingTimeInterval(secondsAtDay).withoutTimeStamp
            if model.eventDate.withoutTimeStamp >= nextDate {
                headerLabel.text = model.eventDate >= nextDate.addingTimeInterval(secondsAtDay) ? R.string
                                                                                                    .localizable
                                                                                                    .match_begins(model.eventDate
                                                                                                                    .format("d MMMM yyyy"),
                                                                                                                  model.eventDate
                                                                                                                        .format("HH:mm")) :
                                                                                                  R.string
                                                                                                    .localizable
                                                                                                    .match_begins_tomorrow(model.eventDate                                        .format("HH:mm"))
                
            } else {
                headerLabel.text = R.string.localizable.match_begins_today(model.eventDate.format("HH:mm"))
            }
        } else {
            headerLabel.text = model.eventDate.format("d MMMM yyyy")
        }
        var prevView: UIView?
        for bet in model.bets {
            let view = BetView()
            view.initUI()
            view.configure(bet)
            prevView = containerView.subviews.last
            containerView.addSubview(view)
            NSLayoutConstraint.activate([
                view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                view.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                view.topAnchor.constraint(equalTo: prevView?.bottomAnchor ?? containerView.topAnchor)
            ])
        }
        containerView.subviews.last?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        layoutIfNeeded()
    }
}
