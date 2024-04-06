//
//  PurchesVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class PurchesVController: FeaureVController {
    
    let titleLabel = UILabel()
    let warningLabel = UILabel()
    let service = PurchesService()
    let blackView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.donates.bind(to: tableView.rx.items(cellIdentifier: DonateCell.reuseIdentifier, cellType: DonateCell.self)) {[weak self] _, item, cell in
            cell.configure(item, self)
        }.disposed(by: disposeBag)
        
        service.endLoad.observe(on: MainScheduler.instance).bind {[weak self] hasProducts in
            self?.warningLabel.isHidden = hasProducts
            self?.activityView.isHidden = true
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        service.endPurche.observe(on: MainScheduler.instance).bind {[weak self] message in
            
            if let message = message {
                self?.showOkAlert(title: R.string.localizable.donate(), message: message)
            }
            self?.tableView.animateOpacity(0.3, 1)
            self?.blackView.animateOpacity(0.3, 0) {[weak self] in
                self?.blackView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name.showMainToolBar, object: nil)
            }
        }.disposed(by: disposeBag)
        
        refresher.rx.controlEvent(UIControl.Event.valueChanged).bind {[weak self] in
            self?.warningLabel.isHidden = true
            self?.service.loadDonates()
        }.disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func initUI() {
        super.initUI()
        navigationBar.hideAuthBtn()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = .textTheme
        titleLabel.text = R.string.localizable.if_you_like_app_pls_support()
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.font = UIFont.systemFont(ofSize: 17)
        warningLabel.textColor = .toolbarItem
        warningLabel.text = R.string.localizable.buy_donate_disable()
        warningLabel.textAlignment = .center
        warningLabel.numberOfLines = 0
        warningLabel.lineBreakMode = .byWordWrapping
        warningLabel.isHidden = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(warningLabel)
        blackView.frame = UIScreen.main.bounds
        blackView.isHidden = true
        blackView.layer.opacity = 0
        blackView.isUserInteractionEnabled = false
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame =  UIScreen.main.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blackView.addSubview(blurEffectView)
        let activity = UIActivityIndicatorView()
        activity.setStyle()
        activity.color = .white
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        blackView.addSubview(activity)
        let imageView = UIImageView(image: R.image.pay())
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        blackView.addSubview(imageView)
        view.addSubview(blackView)
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: blackView.centerYAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: blackView.topAnchor,constant: 250),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            titleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            warningLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            warningLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            warningLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
        ])
        tableView.register(UINib(resource: R.nib.donateCell), forCellReuseIdentifier: DonateCell.reuseIdentifier)
        
        
       
    }
    
    override func titleName() -> String {
        R.string.localizable.screen_paid_title().uppercased()
    }
    override func icon() -> UIImage? {
        R.image.pay()
    }
}

extension PurchesVController: DonateCellDelegate {
    func tapBuy(donate: Donate) {
        if service.makeDotane(donateId: donate.productId) {
            blackView.isHidden = false
            NotificationCenter.default.post(name: Notification.Name.hideMainToolBar, object: nil)
            blackView.animateOpacity(0.5, 1)
        }
    }
    
    
}
