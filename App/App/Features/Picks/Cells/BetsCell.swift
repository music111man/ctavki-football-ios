//
//  ActualBetCell.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit

class BetsCell: UITableViewCell {
    static let heightOfTitle: CGFloat = 26.0
    static let reuseIdentifier = "BetsCell"
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var containerView: UIView!

    var heightConstraint: NSLayoutConstraint?
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.font = UIFont.systemFont(ofSize: 13)
        headerLabel.textColor = R.color.bet_group_header()
        let g = separatorView.setGradient(colors: [.white, R.color.bet_group_header()!, .white], isLine: true)
        g.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width - 20, height: 1))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        gradient?.frame = separatorView.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ model: BetGroup) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        headerLabel.text = model.active ? getFlexibleTimeLeftToMatch(date: model.eventDate) : model.eventDate.format("d MMMM yyyy")
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
    }
    
    func getFlexibleTimeLeftToMatch(date: Date) -> String {
        let secondsAtDay: TimeInterval = 60.0 * 60.0 * 24.0
        let tomorrow = Date().withoutTimeStamp.addingTimeInterval(secondsAtDay)
        var timeLeftMinutes = Int(date.timeIntervalSinceNow) / 60
        let now = Date()
        if timeLeftMinutes <= 0 {
            timeLeftMinutes = timeLeftMinutes * -1
            if timeLeftMinutes <= 45 {
                return R.string.localizable.match_being_played_n_minute("\(timeLeftMinutes)")
            } else {
                if (timeLeftMinutes < 60) {
                    return R.string.localizable.match_being_played_break()
                } else {
                    return R.string.localizable.match_being_played_n_minute("\(timeLeftMinutes - 15)")
                }
            }
        }
        let dateWithoutTimeStamp = date.withoutTimeStamp
        if dateWithoutTimeStamp == tomorrow {
            return R.string.localizable.match_begins_tomorrow(date.format("HH:mm"))
        }
        if  dateWithoutTimeStamp < tomorrow {
            // today
            if (timeLeftMinutes > 6 * 60) {
                return R.string.localizable.match_begins_today(date.format("HH:mm"))
            } else {
                let hours = timeLeftMinutes / 60
                let minutes = timeLeftMinutes - (hours * 60)
                var time = ""
                if hours > 0 {
                    time = R.string.localizable.hours(variablE: hours)
                }
                if minutes > 0 {
                    time = "\(time) \(R.string.localizable.minutes(variablE: minutes))"
                }
                return R.string.localizable.match_begins_in(time)
            }
        }

        return R.string.localizable.match_begins(date.format("d MMMM yyyy"), date.format("HH:mm"))
    }
}
