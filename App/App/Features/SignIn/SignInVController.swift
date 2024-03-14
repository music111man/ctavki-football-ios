//
//  SignInVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import UIKit
import RxSwift

class SignInVController: UIViewController {

    @IBOutlet weak var telegramBtnView: UIView!
    @IBOutlet weak var googleBtnView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var telegramLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let disposeBag = DisposeBag()
    let accountService = AccountService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        titleLabel.text = R.string.localizable.you_are_not_logged_in()
        subTitleLabel.text = R.string.localizable.we_gift_free_bets_to_new_users()
        googleLabel.text = R.string.localizable.log_in_with_google()
        telegramLabel.text = R.string.localizable.log_in_with_telegram()
        closeView.roundCorners()
        containerView.roundCorners(radius: 8)
        googleBtnView.setshadow()
        googleBtnView.roundCorners(radius: 8)
        telegramBtnView.setshadow()
        telegramBtnView.roundCorners(radius: 8)
        view.tap(animateTapGesture: false) {
           UIView.animate(withDuration: 0.3) {[weak self] in
               self?.view.layer.opacity = 0
           } completion: {[weak self] _ in
               self?.dismiss(animated: false)
           }
        }.disposed(by: disposeBag)
        containerView.tap(animateTapGesture: false) { }.disposed(by: disposeBag)
        closeView.tap {[weak self] in
            guard let self = self else { return }
            UIView.transition(with: self.containerView,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft],
                              animations: { [weak self] in
                self?.containerView.layer.opacity = 0
            }) { _ in
                UIView.animate(withDuration: 0.3) {[weak self] in
                    self?.view.layer.opacity = 0
                } completion: {[weak self] _ in
                    self?.dismiss(animated: false)
                }
            }
        }.disposed(by: disposeBag)
        
        googleBtnView.tap {[weak self] in
            self?.accountService.signInByGoogle()
        }.disposed(by: disposeBag)
        
        telegramBtnView.tap {[weak self] in
            self?.accountService.signInByTelegram()
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.transform = .init(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.view.layer.opacity = 1
            self?.containerView.transform = .identity
        }
    }
}
