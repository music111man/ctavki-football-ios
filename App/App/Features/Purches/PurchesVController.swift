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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.donates.bind(to: tableView.rx.items(cellIdentifier: DonateCell.reuseIdentifier, cellType: DonateCell.self)) {[weak self] _, item, cell in
            cell.configure(item, self)
        }.disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.bind { event in
            let translationX = ((event.indexPath.row % 2) > 0 ? 1 : -1) * UIScreen.main.bounds.width
            event.cell.transform = .init(translationX: translationX, y: 0)
            UIView.animate(withDuration: 0.7) {
                event.cell.transform = .identity
            }
        }.disposed(by: disposeBag)
        
        service.endLoad.observe(on: MainScheduler.instance).bind {[weak self] hasProducts in
            self?.warningLabel.isHidden = hasProducts
            self?.activityView.isHidden = true
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        service.endPurche.observe(on: MainScheduler.instance).bind {[weak self] message in
            self?.showAlert(title: R.string.localizable.donate(), message: message)
        }.disposed(by: disposeBag)
        
        service.loadDonates()
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
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20),
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
    
    override func refreshData() -> Bool {
        warningLabel.isHidden = true
        service.loadDonates()
        return true
    }
}

extension PurchesVController: DonateCellDelegate {
    func tapBuy(donate: Donate) {
        if !service.makeDotane(donateId: donate.productId) {
            showAlert(title: R.string.localizable.donate(), message: R.string.localizable.buy_disabled())
        }
    }
    
    
}
