//
//  ForecastPageVController.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 04.04.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class ForecastPageVController: UIViewController {
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var pagesView: UIView!
    
    var selectedBetId: Int!
    let service = ForecastService()
    let disposeBag = DisposeBag()
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var models: [ForecastViewModel]?
    var controllers = [ForecastVController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.setStyle()
        addChild(pageController)
        pagesView.addSubview(pageController.view)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: pagesView.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: pagesView.bottomAnchor),
            pageController.view.leadingAnchor.constraint(equalTo: pagesView.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: pagesView.trailingAnchor)
        ])
        pageController.didMove(toParent: self)
        controllers.append(ForecastVController.createFromNib())
        pageController.setViewControllers(controllers,
                                          direction: .reverse, animated: false)
        
        pageController.dataSource = self
//        pageController.delegate = self
        
        navigationView.setGradient(start: .greenBlueStart,
                                   end: .greenBlueEnd,
                                   isLine: true, index: 0).frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width,
                                                                                                      height: 100))
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateApp).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.stopAnimating()
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen)
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] _ in
            self?.activityView.startAnimating()
            self?.loadForecasts()
        }.disposed(by: disposeBag)
        
        backBtnView.tap {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }.disposed(by: disposeBag)
        
        pageController.rx.didScroll.subscribe {[weak self] completed in
            if completed,
                let model = (self?.pageController.viewControllers?.first as? ForecastVController)?.model {
                self?.titlelabel.text = R.string.localizable.current_bets_m_of_n(model.titleIndex, model.titleCount)
            }
        }.disposed(by: disposeBag)
        
        loadForecasts()
    }
    
    func loadForecasts() {
        service.loadModels().observe(on: MainScheduler.instance).subscribe(onSuccess: {[weak self] models in
            self?.activityView.stopAnimating()
            self?.models = models
            guard let model = models.first(where: { $0.bet.id == self?.selectedBetId }) else {
                if let betId = self?.selectedBetId {
                    NotificationCenter.default.post(name: Notification.Name.needOpenBetDetails,
                                                    object: self,
                                                    userInfo: [BetView.betIdKeyForUserInfo: betId])
                }
                self?.navigationController?.popToRootViewController(animated: false)
                return
            }
            let vc = self?.pageController.viewControllers?.first as? ForecastVController
            vc?.model = model
            vc?.initModelData()
            self?.titlelabel.text = R.string.localizable.current_bets_m_of_n(model.titleIndex, model.titleCount)
        }).disposed(by: disposeBag)
    }
}

extension ForecastPageVController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        getController(viewController: viewController, after: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       getController(viewController: viewController, after: true)
    }
    
    func getController(viewController: UIViewController, after: Bool) -> UIViewController? {
        guard let model = (viewController as? ForecastVController)?.model,
              let betId = after ? models?.last?.bet.id : models?.first?.bet.id,
                betId != model.bet.id,
              let index = models?.firstIndex(where: { $0.bet.id == model.bet.id }),
              let toShowModel = models?[index + (after ? 1 : -1)] else { return nil }
        var controller = controllers.first(where: { $0.model?.bet.id == toShowModel.bet.id  })
        if controller == nil {
            controller = ForecastVController.createFromNib({ vc in
                vc.model = toShowModel
            })
            controllers.append(controller!)
        }
        return controller!
    }
    
}
