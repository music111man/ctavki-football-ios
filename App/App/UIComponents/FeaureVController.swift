//
//  FeaureVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

class FeaureVController: UIViewController {
    
    let disposeBag = DisposeBag()
    let activityView = UIActivityIndicatorView()
    let navigationBar = NavigationTopBarView()
    let tableView = UITableView()
    let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            activityView.style = .large
        } else {
            activityView.style = .whiteLarge
        }
        
        view.backgroundColor = R.color.background_main()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(callNeedRefresh), for: .valueChanged)
        tableView.addSubview(refresher)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        NotificationCenter.default.rx.notification(Notification.Name.badNetRequest).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.deserializeError).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if view.subviews.last != activityView {
            view.bringSubviewToFront(activityView)
        }
    }
   
    func initUI() {
        navigationBar.initUI(parent: view, title: titleName(), icon: icon())
        activityView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            activityView.style = .large
        } else {
            activityView.style = .whiteLarge
        }
        activityView.color = R.color.shadow()
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityView.startAnimating()
    }
    
    func titleName() -> String {
        fatalError("-> Not implemented titleName()!!!")
    }
    
    func icon() -> UIImage? {
        nil
    }
    
    @objc
    private func callNeedRefresh() {
        if !refreshData() {
            refresher.endRefreshing()
        }
    }
    
    func refreshData() -> Bool {
        fatalError("-> Not implemented refreshData()!!!")
    }
}
