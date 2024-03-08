//
//  BetGroupsHeaderView.swift
//  App
//
//  Created by Denis Shkultetskyy on 05.03.2024.
//

import UIKit

final class BetSectionHeaderView: UIView {

    static let height: CGFloat = 55.0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var sectionGradient: CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        sectionGradient = containerView.setGradient(start: R.color.bet_group_start(), end: R.color.bet_group_end(), isLine: true, index: 0)
        containerView.setshadow()
        sectionGradient?.cornerRadius = 5
        containerView.roundCorners(radius: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionGradient?.frame = containerView.bounds
        
    }

    func initUI() {
        sectionGradient = setGradient(start: R.color.bet_group_start(), end: R.color.bet_group_end(), isLine: true)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.tintColor = R.color.text()
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        titleLabel.textColor = R.color.text()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .right
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sumLabel.font = UIFont.boldSystemFont(ofSize: 20)
        sumLabel.textAlignment = .left
        sumLabel.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        view.addSubview(titleLabel)
        view.addSubview(sumLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sumLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            sumLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 3),
            sumLabel.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func configure(monthName: String, sum: Int) {
        titleLabel.text = R.string.localizable.balance_for_month(monthName.uppercased())
        sumLabel.text = "\(sum)$"
        sumLabel.textColor = sum >= 0 ? R.color.won()! : R.color.lost()!
    }
}
