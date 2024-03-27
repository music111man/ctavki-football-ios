//
//  BetResultHeaderView.swift
//  App
//
//  Created by Denis Shkultetskyy on 08.03.2024.
//

import UIKit

class BetResultHeaderView: UIView {

    @IBOutlet weak var upRowImageView: UIImageView!
    @IBOutlet weak var returnView: UIView!
    @IBOutlet weak var betsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tapAnimationView: UIView!
    var gradient: CAGradientLayer!
    
    var returnAction: (() -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        tapAnimationView.roundCorners()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradient = setGradient(start: R.color.blue_gray_500(), end: R.color.blue_gray_300(), isLine: true, index: 0)
        titleLabel.text = nil
        tapAnimationView.isHidden = true
        betsImageView.image = betsImageView.image?.withRenderingMode(.alwaysTemplate)
        returnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnToTop)))
        
        upRowImageView.layer.opacity = 0.8
    }
    
    @objc
    private func returnToTop() {
        tapAnimationView.isHidden = false
        tapAnimationView.transform = .init(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tapAnimationView.transform = .identity
            self?.tapAnimationView.layer.opacity = 0
        } completion: {[weak self] _ in
            self?.tapAnimationView.isHidden = true
            self?.tapAnimationView.layer.opacity = 1
            self?.returnAction?()
        }
    }

    func configure(monthName: String, sum: Int, animateFromBottom: Bool?) {
        guard let animateFromBottom = animateFromBottom else {
            self.titleLabel.text = R.string.localizable.balance_for_month_amount(monthName.uppercased(), sum)
            return
        }
        let offset = animateFromBottom ? bounds.height : -bounds.height
        UIView.animate(withDuration: 0.25) {[weak self] in
            guard let self = self else { return }
            self.titleLabel.transform = CGAffineTransform.init(translationX: 0, y: -offset)
            if animateFromBottom {
                self.titleLabel.layer.opacity = 0
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.titleLabel.text = R.string.localizable.balance_for_month_amount(monthName.uppercased(), sum)
            self.titleLabel.transform = CGAffineTransform.init(translationX: 0, y: offset)
            self.titleLabel.layer.opacity = animateFromBottom ? 1 : 0
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: animateFromBottom ? 1 : 0.7,
                           initialSpringVelocity: 0.3,
                           options: [.curveLinear], animations: {[weak self] in
                self?.titleLabel.transform = CGAffineTransform.identity
                if !animateFromBottom {
                    self?.titleLabel.layer.opacity = 1
                }
                
            })
        }
    }
}
