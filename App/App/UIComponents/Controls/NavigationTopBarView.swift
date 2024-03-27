//
//  NavigationTopBarView.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Notification.Name {
    static let tapAutozire = Notification.Name("tapAutozire")
}

final class NavigationTopBarView: UIView {
    static let height = UIView.safeAreaHeight + 90
    private let titleLabel = UILabel()
    private let disposeBag = DisposeBag()
    private var gradient: CAGradientLayer!
    private let tapAutorizeView = UIView()
    
    var callback: (() -> ())?
    
    var title: String {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text ?? ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    func initUI(parent: UIView, title: String, icon: UIImage?) {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor),
            leftAnchor.constraint(equalTo: parent.leftAnchor),
            rightAnchor.constraint(equalTo: parent.rightAnchor),
            heightAnchor.constraint(equalToConstant: UIView.safeAreaHeight + 90)
        ])
        gradient = setGradient(start: R.color.green_blue_start(), end: R.color.green_blue_end(), isLine: true)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.textColor = R.color.title_color()
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
            
        ])
        
        let iconView = UIImageView(image: icon ?? R.image.arrow_back())
        iconView.contentMode = .scaleToFill
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        
        
            
        let iconContainerView = UIView()
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        let iconHeightAnchor: CGFloat = icon == nil ? 25.0 : 40.0
        let iconWidthAnchor: CGFloat = icon == nil ? 30.0 : 40.0
        NSLayoutConstraint.activate([
            iconContainerView.leftAnchor.constraint(equalTo: leftAnchor),
            iconContainerView.topAnchor.constraint(equalTo: topAnchor),
            iconContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: iconHeightAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconWidthAnchor),
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: iconContainerView.leftAnchor, constant: 15)
        ])
        if icon == nil {
            iconContainerView.tap {[weak self] in
                self?.callback?()
            }.disposed(by: disposeBag)
        }
        
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        rightLabel.textColor = R.color.title_color()
        rightLabel.textAlignment = .right
        rightLabel.numberOfLines = 2
        rightLabel.text = R.string.localizable.sign_in()
        
        let iconImage = UIImageView(image: .user)
        iconImage.tintColor = .title
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        tapAutorizeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapAutorizeView)
        tapAutorizeView.addSubview(rightLabel)
        tapAutorizeView.addSubview(iconImage)
        
        NSLayoutConstraint.activate([
            tapAutorizeView.heightAnchor.constraint(equalToConstant: 80),
            tapAutorizeView.widthAnchor.constraint(equalToConstant: 40),
            tapAutorizeView.rightAnchor.constraint(equalTo: rightAnchor),
            tapAutorizeView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightLabel.rightAnchor.constraint(equalTo: tapAutorizeView.rightAnchor, constant: -10),
            rightLabel.centerYAnchor.constraint(equalTo: tapAutorizeView.centerYAnchor),
            iconImage.heightAnchor.constraint(equalToConstant: 20),
            iconImage.widthAnchor.constraint(equalTo: iconImage.heightAnchor),
            iconImage.centerYAnchor.constraint(equalTo: rightLabel.centerYAnchor),
            iconImage.rightAnchor.constraint(equalTo: tapAutorizeView.rightAnchor,constant: -10)
        ])
        tapAutorizeView.tap {
            NotificationCenter.default.post(name: Notification.Name.tapAutozire, object: nil)
        }.disposed(by: disposeBag)
        
        AppSettings.authorizeEvent.bind { isAutorize in
            if isAutorize {
                iconImage.isHidden = false
                rightLabel.isHidden = true
            } else {
                iconImage.isHidden = true
                rightLabel.isHidden = false
            }
        }.disposed(by: disposeBag)
    }
    
    func hideAuthBtn() {
        tapAutorizeView.isHidden = true
    }
}
