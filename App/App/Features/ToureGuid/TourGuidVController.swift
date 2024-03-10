//
//  StartHelpVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit
import RxSwift
import RxCocoa

class TourGuidVController: UIViewController {
    let disposeBag = DisposeBag()
    
    let betsGuidView = UIView()
    let betsGuidIconContainer = UIView()
    
    let emptyIconContainer = UIView()
    
    let teamsGuidView = UIView()
    let teamsGuidIconContainer = UIView()
    
    let payGuidView = UIView()
    let payGuidIconContainer = UIView()
    
    let faqGuidView = UIView()
    let faqGuidIconContainer = UIView()
    
    let resultGuidView = UIView()
    let resultIconContainer = UIView()
    
    let authorizeGuidView = UIView()
    let authorizeIconContainer = UIView()

    class func create() -> TourGuidVController? {
        TourGuidVController()
    }
    
    typealias SomeAction = () -> Void

    var iconViews = [UIView]()
    var guidViews = [UIView]()
    var guidAnimations = [SomeAction]()
    var endAction: SomeAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconViews.append(contentsOf: [betsGuidIconContainer, teamsGuidIconContainer, payGuidIconContainer, faqGuidIconContainer])
        guidViews.append(contentsOf: [betsGuidView, authorizeGuidView, resultGuidView, teamsGuidView, payGuidView, faqGuidView])
        guidAnimations.append(contentsOf: [betsGuid,
                                           authGuid,
                                           resultGuid,
                                           teamsGuid,
                                           payGuid,
                                           faqGuid,
                                           endGuid])
        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        betsGuidIconContainer.roundCorners()
        authorizeIconContainer.subviews.forEach { $0.layer.cornerRadius = 40 }
        resultIconContainer.subviews.forEach({ $0.roundCorners() })
        iconViews.forEach { $0.roundSubViewCorners() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizeIconContainer.isHidden = true
        resultIconContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guidAnimations.removeFirst()()
    }

    private func initMenuItem(_ title: String, _ image: UIImage?) -> UIView {
        let container = UIView()
        container.backgroundColor = R.color.background_main()
        let icon = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        icon.tintColor =  R.color.selected_toolbar_item()
        icon.contentMode = .scaleToFill
        icon.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = R.color.selected_toolbar_item()
        label.font = UIFont.systemFont(ofSize: 12.0)
        container.addSubview(icon)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 30.0),
            icon.heightAnchor.constraint(equalToConstant: 30.0),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -12),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 17)
        ])
        
        return container
    }
    
    func initMenuContainer(_ containerView: UIView, _ iconView: UIView? = nil, _ prevView: UIView? = nil) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: prevView?.trailingAnchor ?? view.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        guard let iconView = iconView else { return }
        let animationView = UIView()
        animationView.backgroundColor = R.color.background_main()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            iconView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
    }
    
    func initBetsIcon() {
        betsGuidIconContainer.translatesAutoresizingMaskIntoConstraints = false
        betsGuidIconContainer.backgroundColor = .white
        view.addSubview(betsGuidIconContainer)
        NSLayoutConstraint.activate([
            betsGuidIconContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            betsGuidIconContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: UIView.safeAreaHeight + 15),
            betsGuidIconContainer.widthAnchor.constraint(equalToConstant: 50),
            betsGuidIconContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        let animationView = UIView()
        animationView.backgroundColor = .white
        animationView.translatesAutoresizingMaskIntoConstraints = false
        betsGuidIconContainer.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: betsGuidIconContainer.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: betsGuidIconContainer.bottomAnchor),
            animationView.trailingAnchor.constraint(equalTo: betsGuidIconContainer.trailingAnchor),
            animationView.leadingAnchor.constraint(equalTo: betsGuidIconContainer.leadingAnchor)
        ])
        let betsIcon = UIImageView(image: R.image.bets()?.withRenderingMode(.alwaysTemplate))
        betsIcon.translatesAutoresizingMaskIntoConstraints = false
        betsIcon.contentMode = .scaleToFill
        betsIcon.tintColor =  R.color.selected_blue()
        betsGuidIconContainer.addSubview(betsIcon)
        NSLayoutConstraint.activate([
            betsIcon.widthAnchor.constraint(equalToConstant: 30),
            betsIcon.heightAnchor.constraint(equalToConstant: 30),
            betsIcon.centerXAnchor.constraint(equalTo: betsGuidIconContainer.centerXAnchor),
            betsIcon.centerYAnchor.constraint(equalTo: betsGuidIconContainer.centerYAnchor)
        ])
        
    }
    
    func initResultIcon() {
        resultIconContainer.translatesAutoresizingMaskIntoConstraints = false
        resultIconContainer.backgroundColor = .clear
        view.addSubview(resultIconContainer)
        NSLayoutConstraint.activate([
            resultIconContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            resultIconContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultIconContainer.widthAnchor.constraint(equalToConstant: 50),
            resultIconContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        let animationView = UIView()
        animationView.backgroundColor = .white
        animationView.translatesAutoresizingMaskIntoConstraints = false
        resultIconContainer.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: resultIconContainer.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: resultIconContainer.bottomAnchor),
            animationView.trailingAnchor.constraint(equalTo: resultIconContainer.trailingAnchor),
            animationView.leadingAnchor.constraint(equalTo: resultIconContainer.leadingAnchor)
        ])
        let iconView = UIView()
        iconView.backgroundColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        resultIconContainer.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: resultIconContainer.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: resultIconContainer.bottomAnchor),
            iconView.trailingAnchor.constraint(equalTo: resultIconContainer.trailingAnchor),
            iconView.leadingAnchor.constraint(equalTo: resultIconContainer.leadingAnchor)
        ])
        let icon = UIImageView(image: R.image.done()?.withRenderingMode(.alwaysTemplate))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleToFill
        resultIconContainer.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),
            icon.centerXAnchor.constraint(equalTo: resultIconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: resultIconContainer.centerYAnchor)
        ])
        
    }
    
    func initAuthorizeIcon() {
        authorizeIconContainer.translatesAutoresizingMaskIntoConstraints = false
        authorizeIconContainer.backgroundColor = .clear
        view.addSubview(authorizeIconContainer)
        NSLayoutConstraint.activate([
            authorizeIconContainer.widthAnchor.constraint(equalToConstant: 80),
            authorizeIconContainer.heightAnchor.constraint(equalToConstant: 80),
            authorizeIconContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 15),
            authorizeIconContainer.centerYAnchor.constraint(equalTo: betsGuidIconContainer.centerYAnchor, constant: -2)
        ])
        let animationView = UIView()
        animationView.backgroundColor = .white
        animationView.layer.cornerRadius = 40
        animationView.translatesAutoresizingMaskIntoConstraints = false
        authorizeIconContainer.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: authorizeIconContainer.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: authorizeIconContainer.bottomAnchor),
            animationView.trailingAnchor.constraint(equalTo: authorizeIconContainer.trailingAnchor),
            animationView.leadingAnchor.constraint(equalTo: authorizeIconContainer.leadingAnchor)
        ])
        let iconView = UIView()
        iconView.backgroundColor = .white
        iconView.layer.cornerRadius = 40
        iconView.translatesAutoresizingMaskIntoConstraints = false
        authorizeIconContainer.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: authorizeIconContainer.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: authorizeIconContainer.bottomAnchor),
            iconView.trailingAnchor.constraint(equalTo: authorizeIconContainer.trailingAnchor),
            iconView.leadingAnchor.constraint(equalTo: authorizeIconContainer.leadingAnchor)
        ])
        
        let label = UILabel()
        label.text = R.string.localizable.sign_in()
        label.textColor = R.color.selected_blue()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])
    }
    
    func initUI() {

        view.backgroundColor = .clear
        view.isOpaque = true
        guidViews.forEach { $0.backgroundColor = R.color.green_blue_start()?.withAlphaComponent(0.95) }
        initBetsIcon()
        initAuthorizeIcon()
        initResultIcon()
        initMenuContainer(emptyIconContainer)
        
        
        initMenuContainer(teamsGuidIconContainer,
                          initMenuItem(R.string.localizable.teams_cap(), R.image.teams()),
                          emptyIconContainer)
        initMenuContainer(payGuidIconContainer,
                          initMenuItem(R.string.localizable.paid_cap(), R.image.pay()),
                          teamsGuidIconContainer)
        initMenuContainer(faqGuidIconContainer, 
                          initMenuItem(R.string.localizable.questions(), R.image.faq()),
                          payGuidIconContainer)
        
        initBetsGuid()
        initAuthorizeGuid()
        initResultGuid()
        initTeamsGuid()
        initPayGuid()
        initFaqGuid()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextGuidStep)))
        guidViews.forEach { view in
//            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noAction)))
            view.hide()
            view.isHidden = true
        }
        iconViews.forEach({ $0.isHidden = true })
        view.layoutIfNeeded()
    }
    
    func initBetsGuid() {
        betsGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(betsGuidView, at: 0)
        NSLayoutConstraint.activate([
            betsGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.8),
            betsGuidView.heightAnchor.constraint(equalTo: betsGuidView.widthAnchor),
            betsGuidView.centerXAnchor.constraint(equalTo: betsGuidIconContainer.centerXAnchor),
            betsGuidView.centerYAnchor.constraint(equalTo: betsGuidIconContainer.centerYAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        betsGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.heightAnchor.constraint(equalTo: betsGuidView.heightAnchor, multiplier: 0.5),
            textContainer.widthAnchor.constraint(equalTo: textContainer.heightAnchor),
            textContainer.bottomAnchor.constraint(equalTo: betsGuidView.bottomAnchor),
            textContainer.rightAnchor.constraint(equalTo: betsGuidView.rightAnchor)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_bets_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 10),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 60)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_picks()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: -50)
        ])
        
        let labelSkip = UILabel()
        
        labelSkip.text = R.string.localizable.skip()
        labelSkip.textColor = R.color.won_light()
        labelSkip.font = UIFont.boldSystemFont(ofSize: 17.0)
        labelSkip.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(labelSkip)
        NSLayoutConstraint.activate([
            labelSkip.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 0),
            labelSkip.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])
        
        labelSkip.tap { [weak self] in
            guard let self = self  else { return }
            self.guidAnimations.removeAll()
            labelSkip.animateTapGesture(value: 0.8) {
                self.betsGuidIconContainer.layer.opacity = 0
                self.betsGuidView.animateOpacity(0.3, 0) {
                    self.endAction?()
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func initAuthorizeGuid() {
        authorizeGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(authorizeGuidView, at: 0)
        NSLayoutConstraint.activate([
            authorizeGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.75),
            authorizeGuidView.heightAnchor.constraint(equalTo: authorizeGuidView.widthAnchor),
            authorizeGuidView.centerXAnchor.constraint(equalTo: authorizeIconContainer.centerXAnchor),
            authorizeGuidView.centerYAnchor.constraint(equalTo: authorizeIconContainer.centerYAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        authorizeGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.heightAnchor.constraint(equalTo: authorizeGuidView.heightAnchor, multiplier: 0.5),
            textContainer.widthAnchor.constraint(equalTo: textContainer.heightAnchor),
            textContainer.bottomAnchor.constraint(equalTo: authorizeGuidView.bottomAnchor),
            textContainer.leftAnchor.constraint(equalTo: authorizeGuidView.leftAnchor)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_login_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 50),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 60)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_login()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 50),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: -10)
        ])
        
        let labelSkip = UILabel()
        labelSkip.text = R.string.localizable.skip()
        labelSkip.textColor = R.color.won_light()
        labelSkip.font = UIFont.boldSystemFont(ofSize: 17.0)
        labelSkip.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(labelSkip)
        NSLayoutConstraint.activate([
            labelSkip.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 10),
            labelSkip.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])
       
        labelSkip.tap {[weak self] in
            guard let self = self  else { return }
            self.guidAnimations.removeAll()
            labelSkip.animateTapGesture(value: 0.8) {
                self.authorizeIconContainer.layer.opacity = 0
                self.authorizeGuidView.animateOpacity(0.3, 0) {
                    self.endAction?()
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func initResultGuid() {
        resultGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(resultGuidView, at: 0)
        resultGuidView.backgroundColor = R.color.green_blue_start()
        resultGuidView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        NSLayoutConstraint.activate([
            resultGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.5),
            resultGuidView.heightAnchor.constraint(equalTo: resultGuidView.widthAnchor),
            resultGuidView.centerYAnchor.constraint(equalTo: resultIconContainer.centerYAnchor),
            resultGuidView.centerXAnchor.constraint(equalTo: resultIconContainer.centerXAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        resultGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.widthAnchor.constraint(equalTo: resultGuidView.widthAnchor, multiplier: 0.52),
            textContainer.heightAnchor.constraint(equalTo: textContainer.widthAnchor, multiplier: 1),
            textContainer.centerYAnchor.constraint(equalTo: resultGuidView.centerYAnchor),
            textContainer.rightAnchor.constraint(equalTo: resultGuidView.rightAnchor)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_results_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 60),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 10)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_results()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 60),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: textContainer.rightAnchor, constant: -30)
        ])
        let labelSkip = UILabel()
        labelSkip.text = R.string.localizable.skip()
        labelSkip.textColor = R.color.won_light()
        labelSkip.font = UIFont.boldSystemFont(ofSize: 17.0)
        labelSkip.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(labelSkip)
        NSLayoutConstraint.activate([
            labelSkip.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 0),
            labelSkip.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])
        labelSkip.tap { [weak self] in
            guard let self = self  else { return }
            self.guidAnimations.removeAll()
            labelSkip.animateTapGesture(value: 0.8) {
                self.resultIconContainer.layer.opacity = 0
                self.resultGuidView.animateOpacity(0.3, 0) {
                    self.endAction?()
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func initTeamsGuid() {
        teamsGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(teamsGuidView, at: 0)
        NSLayoutConstraint.activate([
            teamsGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.3),
            teamsGuidView.heightAnchor.constraint(equalTo: teamsGuidView.widthAnchor),
            teamsGuidView.centerYAnchor.constraint(equalTo: teamsGuidIconContainer.centerYAnchor),
            teamsGuidView.centerXAnchor.constraint(equalTo: teamsGuidIconContainer.centerXAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        teamsGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.widthAnchor.constraint(equalTo: teamsGuidView.widthAnchor, multiplier: 0.7),
            textContainer.heightAnchor.constraint(equalTo: textContainer.widthAnchor),
            textContainer.centerXAnchor.constraint(equalTo: teamsGuidView.centerXAnchor),
            textContainer.topAnchor.constraint(equalTo: teamsGuidView.topAnchor, constant: 20)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_teams_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 60),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 40)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_teams()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: textContainer.widthAnchor, multiplier: 0.7),
            label.leftAnchor.constraint(equalTo: title.leftAnchor),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10)
        ])
        let labelSkip = UILabel()
        labelSkip.isUserInteractionEnabled = true
        labelSkip.text = R.string.localizable.skip()
        labelSkip.textColor = R.color.won_light()
        labelSkip.font = UIFont.boldSystemFont(ofSize: 17.0)
        labelSkip.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(labelSkip)
        NSLayoutConstraint.activate([
            labelSkip.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 0),
            labelSkip.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])

        labelSkip.tap { [weak self] in
            guard let self = self  else { return }
            self.guidAnimations.removeAll()
            labelSkip.animateTapGesture(value: 0.8) {
                self.teamsGuidIconContainer.layer.opacity = 0
                self.teamsGuidView.animateOpacity(0.3, 0) {
                    self.endAction?()
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func initPayGuid() {
        payGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(payGuidView, at: 0)
        
        NSLayoutConstraint.activate([
            payGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            payGuidView.heightAnchor.constraint(equalTo: payGuidView.widthAnchor),
            payGuidView.centerYAnchor.constraint(equalTo: payGuidIconContainer.centerYAnchor),
            payGuidView.centerXAnchor.constraint(equalTo: payGuidIconContainer.centerXAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        payGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.widthAnchor.constraint(equalTo: payGuidView.widthAnchor, multiplier: 0.7),
            textContainer.heightAnchor.constraint(equalTo: textContainer.widthAnchor),
            textContainer.centerXAnchor.constraint(equalTo: payGuidView.centerXAnchor),
            textContainer.topAnchor.constraint(equalTo: payGuidView.topAnchor, constant: 20)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_paid_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 40),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 40)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_paid_plans()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: textContainer.widthAnchor, multiplier: 0.7),
            label.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 40),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10)
        ])
        let labelSkip = UILabel()
        labelSkip.text = R.string.localizable.skip()
        labelSkip.textColor = R.color.won_light()
        labelSkip.font = UIFont.boldSystemFont(ofSize: 17.0)
        labelSkip.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(labelSkip)
        NSLayoutConstraint.activate([
            labelSkip.leftAnchor.constraint(equalTo: label.leftAnchor, constant: 0),
            labelSkip.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
        ])
        labelSkip.tap {[weak self] in
            guard let self = self  else { return }
            self.guidAnimations.removeAll()
            labelSkip.animateTapGesture(value: 0.8) {
                self.payGuidIconContainer.layer.opacity = 0
                self.payGuidView.animateOpacity(0.3, 0) {
                    self.endAction?()
                }
            }
            
        }.disposed(by: disposeBag)
    }
    
    func initFaqGuid() {
        faqGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(faqGuidView, at: 0)
        NSLayoutConstraint.activate([
            faqGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.4),
            faqGuidView.heightAnchor.constraint(equalTo: faqGuidView.widthAnchor),
            faqGuidView.centerXAnchor.constraint(equalTo: faqGuidIconContainer.centerXAnchor),
            faqGuidView.centerYAnchor.constraint(equalTo: faqGuidIconContainer.centerYAnchor)
        ])
        let textContainer = UIView()
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        faqGuidView.addSubview(textContainer)
        NSLayoutConstraint.activate([
            textContainer.widthAnchor.constraint(equalTo: faqGuidView.widthAnchor, multiplier: 0.5),
            textContainer.heightAnchor.constraint(equalTo: textContainer.widthAnchor),
            textContainer.leftAnchor.constraint(equalTo: faqGuidView.leftAnchor, constant: 70),
            textContainer.topAnchor.constraint(equalTo: faqGuidView.topAnchor, constant: 50)
        ])
        let title = UILabel()
        title.text = R.string.localizable.tooltip_faq_title()
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 17.0)
        title.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(title)
        NSLayoutConstraint.activate([
            title.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 40),
            title.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 40)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_faq()
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: textContainer.widthAnchor, multiplier: 0.7),
            label.leftAnchor.constraint(equalTo: textContainer.leftAnchor, constant: 40),
            label.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10)
        ])
    }
    
    @objc
    func nextGuidStep() {
        if guidAnimations.isEmpty {
            return
        }
        guidAnimations.removeFirst()()
    }
    @objc
    func noAction(){}
    
    func betsGuid() {
        betsGuidView.isHidden = false
        addAnimation(betsGuidIconContainer) {[weak self] in
            guard let self = self else { return }
            self.betsGuidView.show()
            self.betsGuidView.roundCorners()
        }
    }
    
    func teamsGuid() {
        self.teamsGuidView.isHidden = false
        addAnimation(teamsGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.resultGuidView.hide()
            self.resultIconContainer.layer.opacity = 0
            self.teamsGuidView.show()
            self.teamsGuidView.roundCorners()
        }) {
            self.resultGuidView.isHidden = true
            self.resultIconContainer.isHidden = true
        }
    }
    
    func payGuid() {
        payGuidView.isHidden = false
        addAnimation(payGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.teamsGuidView.hide()
            self.teamsGuidIconContainer.layer.opacity = 0
            self.payGuidView.show()
            self.payGuidView.roundCorners()
        }) {
            self.teamsGuidView.isHidden = true
            self.teamsGuidIconContainer.isHidden = true
        }
    }
    
    func faqGuid() {
        faqGuidView.isHidden = false
        addAnimation(faqGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.payGuidView.hide()
            self.payGuidIconContainer.layer.opacity = 0
            self.faqGuidView.show()
            self.faqGuidView.roundCorners()
        }) {
            self.payGuidView.isHidden = true
            self.payGuidIconContainer.isHidden = true
        }
    }
    
    func authGuid() {
        self.authorizeGuidView.isHidden = false
        addAnimation(authorizeIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.betsGuidView.hide()
            self.betsGuidIconContainer.layer.opacity = 0
            self.authorizeGuidView.show()
            self.authorizeGuidView.roundCorners()
        }) {
            self.betsGuidView.isHidden = true
            self.betsGuidIconContainer.isHidden = true
        }
    }
    
    func resultGuid() {
        self.resultGuidView.isHidden = false
        addAnimation(resultIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.authorizeGuidView.layer.opacity = 0
            self.authorizeGuidView.hide()
            self.resultGuidView.show()
            self.resultGuidView.roundCorners()
        }) {
            self.authorizeGuidView.isHidden = true
            self.authorizeIconContainer.isHidden = true
        }
    }
    
    func endGuid() {
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.faqGuidIconContainer.layer.opacity = 0
            self?.faqGuidView.hide()
        }, completion: { [weak self] _ in
            self?.endAction?()
        })
    }
    
    private func addAnimation(_ view: UIView, animation: @escaping () -> Void, _ complation: (() -> Void)? = nil) {
        view.isHidden = false
        view.layer.opacity = 0
        UIView.animate(withDuration: 0.5, animations: {
            view.layer.opacity = 1
            animation()
        }, completion: { _ in
            view.animationView?.transform = CGAffineTransform.identity
            view.animationView?.layer.opacity = 1
            complation?()
            view.superview?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat]) {
                view.animationView?.transform = CGAffineTransform.init(scaleX: 2, y: 2)
                view.animationView?.layer.opacity = 0
            }
        })
    }
}

private extension UIView {
    
    func hide() {
        transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01 )
        layer.opacity = 0
    }
    func show() {
        layer.opacity = 1
        transform = CGAffineTransform.identity
    }
    
    func roundSubViewCorners() {
        animationView?.roundCorners()
        iconView?.roundCorners()
    }
    
    var animationView: UIView? {
        subviews.first
    }
    var iconView: UIView? {
        subviews.last
    }
}
