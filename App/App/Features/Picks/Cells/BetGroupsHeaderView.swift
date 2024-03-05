//
//  BetGroupsHeaderView.swift
//  App
//
//  Created by Denis Shkultetskyy on 05.03.2024.
//

import UIKit

final class BetGroupsHeaderView: UIView {

    let imageView = UIImageView(image: R.image.done()!.withRenderingMode(.alwaysTemplate))
    let titleLabel = UILabel()
    let sumLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
    }

    func initUI() {
        setGradient(start: R.color.bet_group_start()!, end: R.color.bet_group_end()!, isLine: true)
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
        initUI()
        titleLabel.text = R.string.localizable.balance_for_month(monthName.uppercased())
        sumLabel.text = "\(sum)$"
        sumLabel.textColor = sum >= 0 ? R.color.won()! : R.color.lost()!
    }
}
