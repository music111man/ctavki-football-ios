//
//  BetGroupsHeaderView.swift
//  App
//
//  Created by Denis Shkultetskyy on 05.03.2024.
//

import UIKit

final class BetGroupsHeaderView: UIView {

    static let height: CGFloat = 60.0
    
    let imageView = UIImageView(image: R.image.done()!.withRenderingMode(.alwaysTemplate))
    let titleLabel = UILabel()
    let sumLabel = UILabel()
    private var sum: Int?
    var sectionGradient: CALayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionGradient?.frame = bounds
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
        self.sum = sum
        initUI()
        titleLabel.text = R.string.localizable.balance_for_month(monthName.uppercased())
        sumLabel.text = "\(sum)$"
        sumLabel.textColor = sum >= 0 ? R.color.won()! : R.color.lost()!
    }
    
    func updateForHeader(monthName: String, sum: Int) {
        imageView.tintColor = R.color.title_color()
        titleLabel.textColor = R.color.title_color()
        sumLabel.textColor = R.color.title_color()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.titleLabel.layer.opacity = 0
            self?.sumLabel.layer.opacity = 0
        } completion: {[weak self] _ in
            self?.titleLabel.text = R.string.localizable.balance_for_month(monthName.uppercased())
            self?.sumLabel.text = "\(sum)$"
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.titleLabel.layer.opacity = 1
                self?.sumLabel.layer.opacity = 1
            }
        }

        
        
        sectionGradient?.opacity = 0
    }
    
}
