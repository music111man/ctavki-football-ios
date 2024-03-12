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
    @IBOutlet weak var activBetsStackView: UIStackView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    let refresher = UIRefreshControl()
    var isUpdating = false
    var team: Team!
    var historyService: HistoryService!
    let disposeBag = DisposeBag()
    var gradientTop: CAGradientLayer!
    var gradientSubTop: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        historyService = HistoryService(team: team) {[weak self] refresh in
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
        historyService.teamModel.observe(on: MainScheduler.instance).bind {[weak self] model in
            guard let self = self else { return }
            
            self.teamLabel.text = model.title
            self.betsCountLabel.text = "\(model.betsCount)"
            let k = model.amount < 0 ? -1 : 1
            self.amountValLabel.text = "\(model.amount * k)$"
            self.amountValLabel.textColor = model.amount == 0 ? .return : (model.amount > 0 ? .won : .lost)
        }.disposed(by: disposeBag)
        historyService.betGroups.bind(to: tableView.rx.items(cellIdentifier: BetsCell.reuseIdentifier, 
                                                             cellType: BetsCell.self)) { [weak self] _, item, cell in
            cell.configure(item)
            cell.delegate = self
        }.disposed(by: disposeBag)
        
        historyService.activeBetGroups.observe(on: MainScheduler.instance).bind {[weak self] groups in
            guard let self = self else { return }
            self.activBetsStackView.replaceArrangedSubviews({
                groups.map { model in
                    let view: BetsCellView = BetsCellView.fromNib() {v in
                        v.delegate = self
                        v.configure(model)
                        v.transform = .init(scaleX: 0, y: 0)
                    }
                    return view
                }
            }) {
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.activBetsStackView.arrangedSubviews.forEach { $0.transform = .identity }
                }
            }
        }.disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.bind { event in
            event.cell.transform = .init(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.3) {
                event.cell.transform = .identity
            }
        }.disposed(by: disposeBag)
        
        
        
        backView.tap {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientTop.frame = navigationView.bounds
        gradientSubTop.frame = subTitleView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        historyService.updateData()
    }
    
    func initUI() {
        gradientTop = navigationView.setGradient(start: .greenBlueStart, end: .greenBlueEnd, isLine: true, index: 0)
        gradientSubTop = subTitleView.setGradient(start: .betGroupStart, end: .betGroupEnd, isLine: true, index: 0)
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(callNeedRefresh), for: .valueChanged)
        tableView.addSubview(refresher)
        titleLabel.text = R.string.localizable.bets_history().uppercased()
        betsLabel.text = R.string.localizable.bets_made().lowercased()
        amountLabel.text = ", \(R.string.localizable.balance().lowercased())"
        if #available(iOS 13.0, *) {
            activityView.style = .large
        } else {
            activityView.style = .whiteLarge
        }
        tableView.register(UINib(resource: R.nib.betsCell), forCellReuseIdentifier: BetsCell.reuseIdentifier)
    }

    func configure(team: Team) {
        self.team = team
        self.historyService?.team = team
        
    }
    
    @objc
    private func callNeedRefresh() {
        if isUpdating { return }
        
        historyService.updateData()

    }
}

extension HistoryVController: BetViewDelegate {
    func openTeamDetails(team: Team, onLeft: Bool) {
        if historyService.team.id == team.id {
            self.teamLabel.transform = .init(scaleX: 1.2, y: 1.2)
            self.subTitleView.layer.opacity = 0
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20) {[weak self] in
                self?.teamLabel.transform = .identity
                self?.subTitleView.layer.opacity = 1
            }
            return
        }
        historyService.team = team
        UIView.transition(with: containerView,
                          duration: 0.4,
                          options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
                          animations: { [weak self] in
            self?.historyService.updateData()
        }) { _ in
           
        }
    }
}
