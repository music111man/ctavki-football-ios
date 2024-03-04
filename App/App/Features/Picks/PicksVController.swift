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
        tableView.register(UINib(resource: R.nib.actualBetCell), forCellReuseIdentifier: ActualBetCell.reuseIdentifier)
        tableView.separatorStyle = .none
        betsViewModel.actualBetList.bind(to: tableView.rx.items(cellIdentifier: ActualBetCell.reuseIdentifier)) { (section, item, cell) in
            
            let actualBetCell = cell as! ActualBetCell
            actualBetCell.homeTeamNameLabel.text = item.homeTeam?.title
            actualBetCell.goustTeamNameLabel.text = item.goustTeam?.title
            actualBetCell.resultLabel.text = item.result
            
        }.disposed(by: disposeBag)
 
        betsViewModel.updateData()

    }
    
    override func titleName() -> String {
        R.string.localizable.tooltip_bets_title()
    }
    
    override func icon() -> UIImage? {
        R.image.bets()
    }
}

