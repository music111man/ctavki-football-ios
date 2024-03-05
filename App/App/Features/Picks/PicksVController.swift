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

    let tableView = UITableView()
    let betsViewModel = BetsViewModel()
    let disposeBag = DisposeBag()
    var betSections = [BetSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.Name.tryToRefreshData, object: nil)
    }

    override func initUI() {
        super.initUI()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.register(UINib(resource: R.nib.betsCell), forCellReuseIdentifier: BetsCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        
        betsViewModel.updateData() {betSections in
            DispatchQueue.main.async {[weak self] in
                self?.betSections = betSections
                self?.tableView.reloadData()
            }
        }
       

    }
    
    override func titleName() -> String {
        R.string.localizable.tooltip_bets_title()
    }
    
    override func icon() -> UIImage? {
        R.image.bets()
    }
}

extension PicksVController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y - UIView.safeAreaHeight
        
        
        let betCount = betSections.first?.bets.count ?? 0
        let height = CGFloat((betCount *  70) + (betCount * 26))
        if contentOffset > height {
            let offset = contentOffset - height
            if offset < NavigationTopBarView.height { return }
            navigationBar.heightConstraint.constant = NavigationTopBarView.height - offset
        } else {
            let offset = height - contentOffset
            if offset < 0 { return }
            navigationBar.heightConstraint.constant = NavigationTopBarView.height - offset
        }
        view.layoutIfNeeded()
        print("scroll \(contentOffset) = \(height)")
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
            return nil
        }
        let view = BetGroupsHeaderView()
        view.configure(monthName: betSections[section].eventDate!.monthAsString, sum: betSections[section].sum!)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.0 : 60.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(betSections[indexPath.section].bets[indexPath.row].bets.count * 70) + 26.0
    }
}
