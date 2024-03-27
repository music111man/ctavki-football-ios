//
//  PicksVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import UIKit
import RxSwift
import RxCocoa

extension Notification.Name {
    static let tryToShowTourGuid = Notification.Name("tryToShowTourGuid")
}

class PicksVController: FeaureVController {

    var sectionHeaderView: BetResultHeaderView!
    let service = BetsService()
    var betSections = [BetSection]()
    var titleSection: Int = 0
    var isFirstShow = true
    var didScroll = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name.noDataForBetsScreen).subscribe {[weak self] _ in
            guard let self = self else { return }
            self.refresher.endRefreshing()
            self.activityView.isHidden = true
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).subscribe {[weak self] _ in
            self?.activityView.isHidden = false
            self?.activityView.animateOpacity(0.4, 1)
        }.disposed(by: disposeBag)
        
        service.callback = { betSections in
            printAppEvent("update bets \(betSections.count) data in screen")
            if betSections.count == 1 { return }
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.betSections = betSections
                self.setTitle()
                self.tableView.reloadData()
                self.refresher.endRefreshing()
                if !self.activityView.isHidden {
                    self.activityView.animateOpacity(0.5, 0) {
                        self.activityView.isHidden = true
                    }
                }
                self.isFirstShow = false
                NotificationCenter.default.post(name: Notification.Name.tryToShowTourGuid, object: nil)
            }
        }
        service.updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name.tryToRefreshData, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func initUI() {
        super.initUI()
        sectionHeaderView = .fromNib()
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderView.returnAction = {[weak self] in
            self?.tableView.scrollToTop()
        }
        navigationBar.addSubview(sectionHeaderView)
        NSLayoutConstraint.activate([
            sectionHeaderView.topAnchor.constraint(equalTo: navigationBar.topAnchor),
            sectionHeaderView.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
            sectionHeaderView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor),
            sectionHeaderView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
        ])
        sectionHeaderView.transform = .init(translationX: 0, y: NavigationTopBarView.height)
        view.insertSubview(tableView, at: 0)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: -BetSectionHeaderView.height),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UINib(resource: R.nib.betsCell), forCellReuseIdentifier: BetsCell.reuseIdentifier)
        tableView.register(UINib(resource: R.nib.noActiveBetsCell), forCellReuseIdentifier: NoActiveBetsCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        refresher.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            refresher.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 20),
            refresher.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
    }
    
    override func titleName() -> String {
        R.string.localizable.screen_bets_title()
    }
    
    override func icon() -> UIImage? {
        R.image.bets()
    }
    
    override func refreshData() -> Bool {
        if isFirstShow { return false }
        didScroll = false
        NotificationCenter.default.post(name: Notification.Name.tryToRefreshData, object: nil)
        return true
    }
    private func setTitle() {
        
        guard let section = tableView.indexPathsForVisibleRows?.first?.section,
                section != titleSection else { return }
        if section > 0,
           let month = betSections[section].eventDate?.monthAsString,
           let sum = betSections[section].sum {
            if titleSection == 0 {
                sectionHeaderView.configure(monthName: month, sum: sum, animateFromBottom: nil)
                UIView.animate(withDuration: 0.3) {[weak self] in
                    guard let self = self else { return }
                    self.sectionHeaderView.transform = .identity
                }
            } else {
                sectionHeaderView.configure(monthName: month, sum: sum, animateFromBottom: titleSection < section)
            }
        } else {
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self = self else { return }
                self.sectionHeaderView.transform = .init(translationX: 0, y: self.navigationBar.bounds.height)
            }
        }
        titleSection = section
    }
}

extension PicksVController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setTitle()
        if let isEmpty = tableView.indexPathsForVisibleRows?.isEmpty, !isEmpty {
            didScroll = true
        }
    }
}

extension PicksVController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        betSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && betSections[section].bets.isEmpty {
            return 1
        }
        return betSections[section].bets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && betSections[indexPath.section].bets.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoActiveBetsCell.reuseIdentifier, for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: BetsCell.reuseIdentifier, for: indexPath) as! BetsCell
        cell.configure(betSections[indexPath.section].bets[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        let view: BetSectionHeaderView = .fromNib()
        view.configure(monthName: betSections[section].eventDate!.monthAsString, sum: betSections[section].sum!)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        BetSectionHeaderView.height
    }
}

extension PicksVController: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        NotificationCenter.default.post(name: Notification.Name.needOpenHistory, object: self, userInfo: [BetView.teamIdKeyUserInfo: teamId, BetView.tapLeftUserInfo: onLeft])
    }
}
