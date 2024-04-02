//
//  HistoryVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 11.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryVController: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var subTitleView: UIView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountValLabel: UILabel!
    @IBOutlet weak var betsLabel: UILabel!
    @IBOutlet weak var betsCountLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    let refresher = UIRefreshControl()
    var isUpdating = false
    var teamId: Int!
    var historyService: HistoryService!
    let disposeBag = DisposeBag()
    var gradientTop: CAGradientLayer!
    var gradientSubTop: CAGradientLayer!
    let betGroups = BehaviorRelay<[BetGroup]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        historyService = HistoryService(teamId: teamId)
        
        betGroups.bind(to: tableView.rx.items(cellIdentifier: BetsCell.reuseIdentifier,
                                              cellType: BetsCell.self)) { [weak self] _, item, cell in
            cell.configure(item)
            cell.delegate = self
        }.disposed(by: disposeBag)
        
        tableView.rx.didScroll.bind { [weak self] in
            self?.didScroll = true
        }.disposed(by: disposeBag)
        
        backView.tap {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen)
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] _ in
            self?.activityView.isHidden = false
            self?.updateData()
        }.disposed(by: disposeBag)
        
        refresher.rx.controlEvent(UIControl.Event.valueChanged).bind {
            SyncService.shared.refresh {[weak self] hasNew in
                if hasNew {
                    self?.updateData()
                } else {
                    self?.refresher.endRefreshing()
                }
            }
            
        }.disposed(by: disposeBag)
        
        updateData()
    }
    
    func updateData() {
        historyService.load().observe(on: MainScheduler.instance).subscribe {[weak self] model in
            self?.refresher.endRefreshing()
            self?.activityView.isHidden = true
            guard let self = self, let model = model else {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.server_data_error())
                return
            }
            self.teamLabel.text = model.title
            self.betsCountLabel.text = "\(model.betsCount)"
            let k = model.amount < 0 ? -1 : 1
            self.amountValLabel.text = "\(model.amount * k)$"
            self.amountValLabel.textColor = model.amount == 0 ? .return : (model.amount > 0 ? .won : .lost)
            self.betGroups.accept(model.betGroups)
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientTop.frame = navigationView.bounds
    }
    
    var didScroll = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didScroll = false
    }
    
    func initUI() {
        gradientTop = navigationView.setGradient(start: .greenBlueStart, end: .greenBlueEnd, isLine: true, index: 0)
        refresher.attributedTitle = NSAttributedString(string: "")
        tableView.addSubview(refresher)
        titleLabel.text = R.string.localizable.bets_history().uppercased()
        betsLabel.text = R.string.localizable.bets_made().lowercased()
        amountLabel.text = ", \(R.string.localizable.balance().lowercased())"
        activityView.setStyle()
        tableView.register(UINib(resource: R.nib.betsCell), forCellReuseIdentifier: BetsCell.reuseIdentifier)
    }

    func configure(teamId: Int) {
        self.teamId = teamId
        self.historyService?.teamId = teamId
        
    }
}

extension HistoryVController: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        if historyService.teamId == teamId {
            self.teamLabel.transform = .init(scaleX: 1.2, y: 1.2)
            self.subTitleView.layer.opacity = 0
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20) {[weak self] in
                self?.teamLabel.transform = .identity
                self?.subTitleView.layer.opacity = 1
            }
            return
        }
        historyService.teamId = teamId
        activityView.isHidden = false
        updateData()
    }
}
