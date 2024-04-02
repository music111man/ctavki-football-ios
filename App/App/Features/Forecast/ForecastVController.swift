//
//  ForecastVController.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 17.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

class ForecastVController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet var redCircles: [UIView]!
    @IBOutlet var violetCircles: [UIView]!

    @IBOutlet var blueGreenCircles: [UIView]!

    @IBOutlet weak var typeTitleLabel: UILabel!
    @IBOutlet weak var seriaTeam2Label: UILabel!
    @IBOutlet weak var seriaTeam1Label: UILabel!
    @IBOutlet weak var seriatitleLabel: UILabel!
    @IBOutlet weak var roiTeam2Label: UILabel!
    @IBOutlet weak var roiTeam1Label: UILabel!
    @IBOutlet weak var roiTitleLabel: UILabel!
    @IBOutlet weak var avgTeam2Label: UILabel!
    @IBOutlet weak var avgTeam1Label: UILabel!
    @IBOutlet weak var avgTitleLabel: UILabel!
    @IBOutlet weak var lostTeam2Label: UILabel!
    @IBOutlet weak var lostTeam1Label: UILabel!
    @IBOutlet weak var lostTitleLabel: UILabel!
    @IBOutlet weak var winTeam2Label: UILabel!
    @IBOutlet weak var winTeam1Label: UILabel!
    @IBOutlet weak var winTitleLabel: UILabel!
    @IBOutlet weak var countTeam2Label: UILabel!
    @IBOutlet weak var countTeam1Label: UILabel!
    @IBOutlet weak var countTitleLabel: UILabel!
    @IBOutlet weak var comparisonLabel: UILabel!
    @IBOutlet weak var coeffLabel: UILabel!
    @IBOutlet weak var coeffValLabel: UILabel!
    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var teamLabel2: UILabel!
    @IBOutlet weak var teamLabel1: UILabel!
    @IBOutlet weak var teamView2: UIView!
    @IBOutlet weak var teamView1: UIView!
    @IBOutlet var gradientsBlueGreen: [UIView]!
    @IBOutlet var separators: [UIView]!
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var titlelabel: UILabel!
    
    let refresher = UIRefreshControl()
    let disposeBag = DisposeBag()
    let service = ForecastService()
    
    private var model: ForecastViewModel? {
        didSet {
            guard let m = model else { return }
            titlelabel.text = R.string.localizable.current_bets_m_of_n(m.titleIndex, m.titleCount)
            matchTimeLabel.text = BetsCell.getFlexibleTimeLeftToMatch(date: m.bet.eventDate)
            forecastLabel.text = m.betTypeTitle
            teamLabel1.text = m.team1.title
            teamLabel2.text = m.team2.title
            coeffValLabel.text = m.bet.factor?.formattedString ?? "?"
            countTeam1Label.text = m.betCount1.asString
            countTeam2Label.text = m.betCount2.asString
            winTeam1Label.text = m.winCount1.asString
            winTeam2Label.text = m.winCount2.asString
            lostTeam1Label.text = m.lostCount1.asString
            lostTeam2Label.text = m.lostCount2.asString
            avgTeam1Label.text = m.avg1.formattedString
            avgTeam2Label.text = m.avg2.formattedString
            roiTeam1Label.text = m.roi1.formattedString(count: 1)
            roiTeam2Label.text = m.roi2.formattedString(count: 1)
            seriaTeam1Label.text = m.seria1.asString
            seriaTeam2Label.text = m.seria2.asString
        }
    }
    
    var betId: Int {
        get { service.betId }
        set { service.betId = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.setStyle()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.rx.controlEvent(UIControl.Event.valueChanged).bind {
            SyncService.shared.refresh {[weak self] hasNew in
                if hasNew {
                    self?.loadForecast()
                } else {
                    self?.refresher.endRefreshing()
                }
            }
            
        }.disposed(by: disposeBag)
        scrollView.addSubview(refresher)
        initLabels()
        initGradients()
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen)
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] _ in
            self?.activityView.isHidden = false
            self?.loadForecast()
        }.disposed(by: disposeBag)
        
        teamView1.tap {[weak self] in
            guard let teamId = self?.model?.team1.id else { return }
            let vc: HistoryVController = .createFromNib { vc in
                vc.configure(teamId: teamId)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            
        }.disposed(by: disposeBag)
        teamView2.tap {[weak self] in
            guard let teamId = self?.model?.team2.id else { return }
            let vc: HistoryVController = .createFromNib { vc in
                vc.configure(teamId: teamId)
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        backBtnView.tap {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: disposeBag)
        
        loadForecast()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GoogleAnaliticsService.logViewVisited(param: .betId(betId))
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientsBlueGreen.forEach { $0.layer.sublayers?.first?.frame = $0.bounds }
        blueGreenCircles.forEach { $0.layer.sublayers?.first?.frame = $0.bounds }
        violetCircles.forEach { $0.layer.sublayers?.first?.frame = $0.bounds }
        redCircles.forEach { $0.layer.sublayers?.first?.frame = $0.bounds }
    }

    func initLabels() {
        forecastLabel.text = R.string.localizable.accurate_match_prediction().lowercased()
        coeffLabel.text = R.string.localizable.bets_odds()
        typeTitleLabel.text = R.string.localizable.accurate_match_prediction()
        comparisonLabel.text = R.string.localizable.teams_comparison()
        countTitleLabel.text = R.string.localizable.total_bets().lowercased()
        winTitleLabel.text = R.string.localizable.wins().lowercased()
        lostTitleLabel.text = R.string.localizable.loses().lowercased()
        avgTitleLabel.text = R.string.localizable.average_coeff().lowercased()
        roiTitleLabel.text = R.string.localizable.roi_percentage()
        seriatitleLabel.text = R.string.localizable.current_series().lowercased()
    }
    func initGradients() {
        separators.forEach { separatorView in
            separatorView.setGradient(colors: [.backgroundMain,
                                               .betGroupHeader,
                                               .backgroundMain], isLine: true)
                        .frame = CGRect(origin: CGPoint.zero,
                                        size: CGSize(width: UIScreen.main.bounds.width - 30, height: 1))
        }
        
        gradientsBlueGreen.forEach { view in
            view.setGradient(start: .greenBlueStart,
                             end: .greenBlueEnd,
                             isLine: true, index: 0)
        }
        blueGreenCircles.forEach { view in
            view.setGradient(start: .greenBlueEnd,
                             end: .greenBlueStart,
                             isLine: false, index: 0)
        }
        violetCircles.forEach { view in
            view.setGradient(start: .viotetStart,
                             end: .violetEnd,
                             isLine: false, index: 0)
        }
        redCircles.forEach { view in
            view.setGradient(start: .redStart,
                             end: .redEnd,
                             isLine: false, index: 0)
        }
    }
    
    private func loadForecast() {
        service.load().observe(on: MainScheduler.instance).subscribe {[weak self] model in
            self?.model = model
            self?.activityView.isHidden = true
            self?.refresher.endRefreshing()
            if model == nil {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.server_data_error())
            }
        }.disposed(by: disposeBag)
    }
    
    func animate(onLeft: Bool, _ complite: @escaping() -> ()) {

        UIView.transition(with: backView,
                          duration: 0.4,
                          options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
                          animations: {[weak self] in
            self?.backView.layer.opacity = 0
            
        }) {[weak self] _ in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) { [weak self] in
                self?.backView.layer.opacity = 1
            }
            complite()
        }
        
        return
    }
}
