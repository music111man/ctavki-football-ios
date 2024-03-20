//
//  DonateCell.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 19.03.2024.
//

import UIKit
import RxSwift

protocol DonateCellDelegate: AnyObject {
    func tapBuy(donate: Donate)
}

class DonateCell: UITableViewCell {

    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var gradient: CAGradientLayer!
    var donate: Donate?
    private weak var delegate: DonateCellDelegate?
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradient = containerView.setGradient(start: .greenBlueStart, end: .greenBlueEnd, isLine: nil, index: 0)
        
        bottomContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        buyLabel.text = R.string.localizable.buy()
        buyView.tap {[weak self] in
            guard let donate = self?.donate else { return }
            self?.delegate?.tapBuy(donate: donate)
        }.disposed(by: disposeBag)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width,
                                                            height: containerView.bounds.height - bottomContainerView.bounds.height))
    }
    
    func configure(_ donate: Donate, _ delegate: DonateCellDelegate?) {
        self.donate = donate
        self.delegate = delegate
        titleLabel.text = "\(donate.name) - \(donate.priceWithCurrency)"
        descLabel.text = donate.description
    }
    
}
