//
//  PicksVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class PicksVController: FeaureVController {

    let sectionHeaderView = UIView()
    var sectionHeaderViewGradient: CALayer!
    let sectionHeaderInfoView = BetGroupsHeaderView()
    let betsViewModel = BetsViewModel()
    var betSections = [BetSection]()
    var titleSection: Int = 0
    var isFirstShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name.noDataForBetsScreen).subscribe {[weak self] _ in
            guard let self = self else { return }
            if self.isFirstShow {
                self.betsViewModel.updateData()
            }
            self.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).subscribe {[weak self] _ in
            self?.activityView.isHidden = false
            self?.activityView.animateOpacity(0.4, 1)
            
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.needOpenTeamDetails).subscribe {[weak self] event in
            guard let teamId = event.element?.userInfo?[BetView.teamIdKeyForUserInfo] as? Int else {
                return
            }
            
                let alert = UIAlertController(title: "Will show team details for team id=\(teamId)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self?.navigationController?.present(alert, animated: true, completion: nil)
            
        }.disposed(by: disposeBag)
        
        betsViewModel.callback = { betSections in
            printAppEvent("update bets data in screen")
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
            }
        }
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
        sectionHeaderViewGradient.frame = sectionHeaderView.bounds
    }
    
    override func initUI() {
        super.initUI()
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderViewGradient = sectionHeaderView.setGradient(start: R.color.blue_gray_500(), end: R.color.blue_gray_250(), isLine: true)
        view.insertSubview(sectionHeaderView, at: 0)
        NSLayoutConstraint.activate([
            sectionHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            sectionHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sectionHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sectionHeaderView.heightAnchor.constraint(equalToConstant: NavigationTopBarView.height)
        ])
        sectionHeaderInfoView.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderView.addSubview(sectionHeaderInfoView)
        NSLayoutConstraint.activate([
            sectionHeaderInfoView.heightAnchor.constraint(equalToConstant: BetGroupsHeaderView.height),
            sectionHeaderInfoView.leftAnchor.constraint(equalTo: sectionHeaderView.leftAnchor),
            sectionHeaderInfoView.rightAnchor.constraint(equalTo: sectionHeaderView.rightAnchor),
            sectionHeaderInfoView.bottomAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor, constant: -20)
        ])
        sectionHeaderInfoView.initUI()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(tableView, at: 0)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.sectionHeaderView.bottomAnchor, constant: -BetGroupsHeaderView.height),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UINib(resource: R.nib.betsCell), forCellReuseIdentifier: BetsCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
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
        NotificationCenter.default.post(name: Notification.Name.tryToRefreshData, object: nil)
        return true
    }
}

extension PicksVController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y - UIView.safeAreaHeight
        let height = (betSections.first?.cellHeight ?? 0) + BetGroupsHeaderView.height
        if contentOffset > height {
            setTitle()
            if navigationBar.isHidden { return }
            self.sectionHeaderInfoView.layer.opacity = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.navigationBar.layer.opacity = 0
                self.sectionHeaderInfoView.layer.opacity = 1
            }) {_ in
                self.navigationBar.isHidden = true
            }
            navigationBar.isHidden = true
        } else {
            if self.navigationBar.layer.opacity == 1 { return }
            
            self.navigationBar.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.navigationBar.layer.opacity = 1
            }
        }
    }
    
    func setTitle() {
        
        guard let section = tableView.indexPathsForVisibleRows?.first?.section, 
                section != titleSection,
                section > 0,
                let month = betSections[section].eventDate?.monthAsString,
                let sum = betSections[section].sum else { return }
        
        titleSection = section
        sectionHeaderInfoView.updateForHeader(monthName: month, sum: sum)
    }
}

extension PicksVController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        betSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        betSections[section].bets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BetsCell.reuseIdentifier, for: indexPath) as! BetsCell
        cell.configure(betSections[indexPath.section].bets[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UIView()
        }
        let view = BetGroupsHeaderView()
        view.configure(monthName: betSections[section].eventDate!.monthAsString, sum: betSections[section].sum!)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        BetGroupsHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            cell.transform = CGAffineTransform.identity
        }
    }
}
