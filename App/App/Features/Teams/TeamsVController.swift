//
//  TeamsVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class TeamsVController: FeaureVController {
    
    var teamsService: TeamsService!
    var isUpdating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamsService = TeamsService {[weak self] refresh in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isUpdating = refresh
                if refresh {
                    if self.refresher.isRefreshing { return }
                    self.activityView.isHidden = false
                    self.activityView.animateOpacity(0.2, 1)
                    
                    return
                }
                self.refresher.endRefreshing()
                self.activityView.animateOpacity(0.2, 0) {[weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
        
        teamsService.teams.bind(to: tableView.rx.items(cellIdentifier: TeamsViewCell.reuseIdentifier,
                                                       cellType: TeamsViewCell.self)) { [weak self] _, item, cell in
            cell.delegate = self
            cell.configure(model: item)
        }.disposed(by: disposeBag)
        
        teamsService.updateData()
    }
    
    override func initUI() {
        super.initUI()
        navigationBar.hideAuthBtn()
        tableView.register(UINib(resource: R.nib.teamsViewCell), forCellReuseIdentifier: TeamsViewCell.reuseIdentifier)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.tableView.transform = .identity
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func titleName() -> String {
        R.string.localizable.screen_teams_title()
    }
    
    override func icon() -> UIImage? {
        R.image.teams()
    }
    
    override func refreshData() -> Bool {
        
        if isUpdating { return false }
        
        teamsService.updateData()
        
        return true
    }
}

extension TeamsVController: BetViewDelegate {
    func openTeamDetails(team: Team, onLeft: Bool) {
        let vc: HistoryVController = .createFromNib { vc in
            vc.configure(team: team)
        }
//        UIView.transition(with: view,
//                          duration: 0.4,
//                          options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
//                          animations: { [weak self] in
//            self?.view.layer.opacity = 0
//        }) {[weak self] _ in
//            self?.view.layer.opacity = 1
//            self?.navigationController?.pushViewController(vc, animated: false)
//        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.tableView.transform = .init(scaleX: 0.01, y: 0.01)
        } completion: { [weak self] _ in
            self?.navigationController?.pushViewController(vc, animated: true)
        }

    }
}
