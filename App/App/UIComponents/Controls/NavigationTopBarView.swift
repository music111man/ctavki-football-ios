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
    private let tapAuthAnimate = UIView()
    private var tapBackAnimate: UIView?
    private let disposeBag = DisposeBag()
    private var gradient: CAGradientLayer!
    
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
            let tapBackAnimate = UIView()
            tapBackAnimate.translatesAutoresizingMaskIntoConstraints = false
            tapBackAnimate.backgroundColor = R.color.green_blue_end()
            tapBackAnimate.layer.opacity = 0
            iconContainerView.insertSubview(tapBackAnimate, at: 0)
            NSLayoutConstraint.activate([
                tapBackAnimate.widthAnchor.constraint(equalToConstant: 120),
                tapBackAnimate.heightAnchor.constraint(equalToConstant: 120),
                tapBackAnimate.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                tapBackAnimate.centerXAnchor.constraint(equalTo: iconView.centerXAnchor)
            ])
            tapBackAnimate.layer.cornerRadius = 60
            self.tapBackAnimate = tapBackAnimate
            let tapGesture = UITapGestureRecognizer()
            tapGesture.rx.event.bind {[weak self] _ in
                self?.tapBackAnimate?.layer.opacity = 1
                self?.tapBackAnimate?.transform = CGAffineTransform.init(scaleX: 0, y: 0)
                UIView.animate(withDuration: 0.3) {
                    self?.tapBackAnimate?.transform = CGAffineTransform.identity
                    self?.tapBackAnimate?.layer.opacity = 0
                } completion: {[weak self] _ in
                    self?.callback?()
                }
                
            }.disposed(by: disposeBag)
            iconContainerView.addGestureRecognizer(tapGesture)
        }
        
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        rightLabel.textColor = R.color.title_color()
        rightLabel.textAlignment = .right
        rightLabel.numberOfLines = 2
        let tapAutorizeView = UIView()
        tapAutorizeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapAutorizeView)
        tapAuthAnimate.backgroundColor = R.color.green_blue_start()
        tapAuthAnimate.layer.cornerRadius = 60
        tapAuthAnimate.translatesAutoresizingMaskIntoConstraints = false
        tapAutorizeView.addSubview(tapAuthAnimate)
        tapAutorizeView.addSubview(rightLabel)
        
        
        NSLayoutConstraint.activate([
            tapAutorizeView.heightAnchor.constraint(equalToConstant: 80),
            tapAutorizeView.widthAnchor.constraint(equalToConstant: 40),
            tapAutorizeView.rightAnchor.constraint(equalTo: rightAnchor),
            tapAutorizeView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            tapAuthAnimate.centerXAnchor.constraint(equalTo: tapAutorizeView.centerXAnchor),
            tapAuthAnimate.centerYAnchor.constraint(equalTo: tapAutorizeView.centerYAnchor),
            tapAuthAnimate.heightAnchor.constraint(equalToConstant: 120),
            tapAuthAnimate.widthAnchor.constraint(equalToConstant: 120),
            rightLabel.rightAnchor.constraint(equalTo: tapAutorizeView.rightAnchor, constant: -10),
            rightLabel.centerYAnchor.constraint(equalTo: tapAutorizeView.centerYAnchor)
        ])
        let tapGestore = UITapGestureRecognizer()
        tapAuthAnimate.layer.opacity = 0
        tapGestore.rx.event.bind {[weak self] _ in
            self?.tapAuthAnimate.layer.opacity = 1
            self?.tapAuthAnimate.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.3) {
                self?.tapAuthAnimate.transform = CGAffineTransform.identity
                self?.tapAuthAnimate.layer.opacity = 0
            } completion: { _ in
                NotificationCenter.default.post(name: Notification.Name.tapAutozire, object: nil)
            }
        }.disposed(by: disposeBag)
        tapAutorizeView.addGestureRecognizer(tapGestore)
        
        AppSettings.authorizeEvent.bind { isAutorize in
            rightLabel.text = isAutorize ? R.string.localizable.my_balance() : R.string.localizable.sign_in()
        }.disposed(by: disposeBag)
    }
}
