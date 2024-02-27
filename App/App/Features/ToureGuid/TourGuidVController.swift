//
//  StartHelpVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

class TourGuidVController: UIViewController {
    
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

    lazy var safeAreaHeight: CGFloat = {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        return window.frame.maxY - safeFrame.maxY
    }()
    
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
        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        betsGuidIconContainer.layer.cornerRadius = betsGuidIconContainer.frame.width / 2
        authorizeIconContainer.subviews.forEach { $0.layer.cornerRadius = 40 }
        resultIconContainer.subviews.forEach({ $0.layer.cornerRadius = $0.frame.width / 2 })
        iconViews.forEach { $0.roundCorners() }
        betsGuidView.layer.cornerRadius = betsGuidView.frame.width / 3
        authorizeGuidView.layer.cornerRadius = authorizeGuidView.frame.width / 3
        resultGuidView.layer.cornerRadius = resultGuidView.frame.height / 2
        teamsGuidView.layer.cornerRadius = teamsGuidView.frame.width / 2
        payGuidView.layer.cornerRadius = payGuidView.frame.width / 2
        faqGuidView.layer.cornerRadius = faqGuidView.frame.width / 3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        betsGuidView.isHidden = true
        betsGuidView.transform = CGAffineTransform.init(translationX: -betsGuidView.frame.width, y: -betsGuidView.frame.height)
        authorizeGuidView.isHidden = true
        authorizeGuidView.transform = CGAffineTransform.init(translationX: authorizeGuidView.frame.width, y: -authorizeGuidView.frame.height)
        teamsGuidView.isHidden = true
        teamsGuidView.transform = CGAffineTransform.init(translationX: 0, y: teamsGuidView.frame.height)
        payGuidView.isHidden = true
        payGuidView.transform = CGAffineTransform.init(translationX: 0, y: payGuidView.frame.height)
        faqGuidView.isHidden = true
        faqGuidView.transform = CGAffineTransform.init(translationX: payGuidView.frame.width, y: payGuidView.frame.height)
        iconViews.forEach({ $0.isHidden = true })
        authorizeIconContainer.isHidden = true
        
        resultIconContainer.isHidden = true
        resultGuidView.isHidden = true
        resultGuidView.transform = CGAffineTransform.init(translationX: -resultGuidView.frame.width, y: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guidAnimations.removeFirst()()
    }

    private func initMenuItem(_ title: String, _ image: UIImage?) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        let icon = UIImageView(image: image)
        icon.contentMode = .scaleToFill
        icon.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.textColor = .black
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
        animationView.backgroundColor = .white
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
            betsGuidIconContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            betsGuidIconContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: safeAreaHeight + 20),
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
        let betsIcon = UIImageView(image: R.image.bets())
        betsIcon.translatesAutoresizingMaskIntoConstraints = false
        betsIcon.contentMode = .scaleToFill
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
            resultIconContainer.widthAnchor.constraint(equalToConstant: 35),
            resultIconContainer.heightAnchor.constraint(equalToConstant: 35)
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
        iconView.backgroundColor = R.color.blue_gray_400()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        resultIconContainer.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: resultIconContainer.topAnchor),
            iconView.bottomAnchor.constraint(equalTo: resultIconContainer.bottomAnchor),
            iconView.trailingAnchor.constraint(equalTo: resultIconContainer.trailingAnchor),
            iconView.leadingAnchor.constraint(equalTo: resultIconContainer.leadingAnchor)
        ])
        let icon = UIImageView(image: R.image.done())
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleToFill
        resultIconContainer.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 30),
            icon.heightAnchor.constraint(equalToConstant: 30),
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
            authorizeIconContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 40),
            authorizeIconContainer.centerYAnchor.constraint(equalTo: betsGuidIconContainer.centerYAnchor)
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
        iconView.backgroundColor = R.color.authorize_btn()
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
        label.text = R.string.localizable.my_balance()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: iconView.leftAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ])
    }
    
    func initUI() {

        view.backgroundColor = .clear
        view.isOpaque = true
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
        
        guidAnimations.append(contentsOf: [betsGuid,
                                           authGuid,
                                           resultGuid,
                                           teamsGuid,
                                           payGuid,
                                           faqGuid,
                                           endGuid])
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nextGuidStep)))
        guidViews.forEach { view in
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noAction)))
        }
        view.layoutIfNeeded()
    }
    
    func initBetsGuid() {
        betsGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(betsGuidView, at: 0)
        betsGuidView.backgroundColor = R.color.green_blue_start()
        betsGuidView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        NSLayoutConstraint.activate([
            betsGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            betsGuidView.heightAnchor.constraint(equalTo: betsGuidView.widthAnchor, multiplier: 0.7),
            betsGuidView.topAnchor.constraint(equalTo: view.topAnchor, constant: -10),
            betsGuidView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -10)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_picks()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        betsGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: betsGuidView.widthAnchor, multiplier: 0.6),
            label.rightAnchor.constraint(equalTo: betsGuidView.rightAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: betsGuidView.bottomAnchor, constant: -45)
        ])
    }
    
    func initAuthorizeGuid() {
        authorizeGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(authorizeGuidView, at: 0)
        authorizeGuidView.backgroundColor = R.color.green_blue_start()
        authorizeGuidView.layer.maskedCorners = [.layerMinXMaxYCorner]
        NSLayoutConstraint.activate([
            authorizeGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            authorizeGuidView.heightAnchor.constraint(equalTo: authorizeGuidView.widthAnchor, multiplier: 0.7),
            authorizeGuidView.topAnchor.constraint(equalTo: view.topAnchor, constant: -10),
            authorizeGuidView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_login()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        authorizeGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: authorizeGuidView.widthAnchor, multiplier: 0.6),
            label.leftAnchor.constraint(equalTo: authorizeGuidView.leftAnchor, constant: 30),
            label.bottomAnchor.constraint(equalTo: authorizeGuidView.bottomAnchor, constant: -20)
        ])
    }
    
    func initResultGuid() {
        resultGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(resultGuidView, at: 0)
        resultGuidView.backgroundColor = R.color.green_blue_start()
        resultGuidView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        NSLayoutConstraint.activate([
            resultGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            resultGuidView.heightAnchor.constraint(equalTo: resultGuidView.widthAnchor, multiplier: 0.4),
            resultGuidView.centerYAnchor.constraint(equalTo: resultIconContainer.centerYAnchor),
            resultGuidView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_results()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        resultGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: resultGuidView.widthAnchor, multiplier: 0.6),
            label.rightAnchor.constraint(equalTo: resultGuidView.rightAnchor, constant: -30),
            label.centerYAnchor.constraint(equalTo: resultGuidView.centerYAnchor)
        ])
    }
    
    func initTeamsGuid() {
        teamsGuidView.translatesAutoresizingMaskIntoConstraints = false
        teamsGuidView.backgroundColor = R.color.green_blue_start()
        teamsGuidView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.insertSubview(teamsGuidView, at: 0)
        
        NSLayoutConstraint.activate([
            teamsGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            teamsGuidView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.27),
            teamsGuidView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            teamsGuidView.centerXAnchor.constraint(equalTo: teamsGuidIconContainer.centerXAnchor)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_teams()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        teamsGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: teamsGuidView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: teamsGuidView.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: teamsGuidView.topAnchor, constant: 40)
        ])
    }
    
    func initPayGuid() {
        payGuidView.translatesAutoresizingMaskIntoConstraints = false
        payGuidView.backgroundColor = R.color.green_blue_start()
        payGuidView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.insertSubview(payGuidView, at: 0)
        
        NSLayoutConstraint.activate([
            payGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.39),
            payGuidView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.32),
            payGuidView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            payGuidView.centerXAnchor.constraint(equalTo: payGuidIconContainer.centerXAnchor)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_paid_plans()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        payGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: payGuidView.leadingAnchor, constant: 17),
            label.trailingAnchor.constraint(equalTo: payGuidView.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: payGuidView.topAnchor, constant: 55)
        ])
    }
    
    func initFaqGuid() {
        faqGuidView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(faqGuidView, at: 0)
        faqGuidView.backgroundColor = R.color.green_blue_start()
        faqGuidView.layer.maskedCorners = [.layerMinXMinYCorner]
        NSLayoutConstraint.activate([
            faqGuidView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            faqGuidView.heightAnchor.constraint(equalTo: faqGuidView.widthAnchor),
            faqGuidView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10),
            faqGuidView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10)
        ])
        let label = UILabel()
        label.text = R.string.localizable.guid_faq()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .right
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        faqGuidView.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: faqGuidView.widthAnchor, multiplier: 0.6),
            label.leftAnchor.constraint(equalTo: faqGuidView.leftAnchor, constant: 30),
            label.topAnchor.constraint(equalTo: faqGuidView.topAnchor, constant: 20)
        ])
    }
    
    @objc
    func nextGuidStep() {
        guidAnimations.removeFirst()()
    }
    @objc
    func noAction(){}
    
    func betsGuid() {
        betsGuidView.isHidden = false
        addAnimation(betsGuidIconContainer) {[weak self] in
            self?.betsGuidView.transform = CGAffineTransform.identity
        }
    }
    
   
    
    func teamsGuid() {
        self.teamsGuidView.isHidden = false
        addAnimation(teamsGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.resultGuidView.layer.opacity = 0
            self.resultIconContainer.layer.opacity = 0
            self.teamsGuidView.transform = CGAffineTransform.identity
        }) {
            self.resultGuidView.isHidden = true
            self.resultIconContainer.isHidden = true
        }
    }
    
    func payGuid() {
        payGuidView.isHidden = false
        addAnimation(payGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.teamsGuidView.layer.opacity = 0
            self.teamsGuidIconContainer.layer.opacity = 0
            self.payGuidView.transform = CGAffineTransform.identity
        }) {
            self.teamsGuidView.isHidden = true
            self.teamsGuidIconContainer.isHidden = true
        }
    }
    
    func faqGuid() {
        faqGuidView.isHidden = false
        addAnimation(faqGuidIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.payGuidView.layer.opacity = 0
            self.payGuidIconContainer.layer.opacity = 0
            self.faqGuidView.transform = CGAffineTransform.identity
        }) {
            self.payGuidView.isHidden = true
            self.payGuidIconContainer.isHidden = true
        }
    }
    
    func authGuid() {
        self.authorizeGuidView.isHidden = false
        addAnimation(authorizeIconContainer, animation: {[weak self] in
            guard let self = self else { return }
            self.betsGuidView.layer.opacity = 0
            self.betsGuidIconContainer.layer.opacity = 0
            self.authorizeGuidView.transform = CGAffineTransform.identity
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
            self.authorizeIconContainer.layer.opacity = 0
            self.resultGuidView.transform = CGAffineTransform.identity
        }) {
            self.authorizeGuidView.isHidden = true
            self.authorizeIconContainer.isHidden = true
        }
    }
    
    func endGuid() {
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.faqGuidIconContainer.layer.opacity = 0
            self?.faqGuidView.layer.opacity = 0
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
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat]) {
                view.animationView?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                view.animationView?.layer.opacity = 0
            }
        })
    }
}

private extension UIView {
    
    func roundCorners() {
        guard let width = subviews.first?.frame.width else { return }
        animationView?.layer.cornerRadius = width / 2
        iconView?.layer.cornerRadius = width / 2
    }
    
    var animationView: UIView? {
        subviews.first
    }
    var iconView: UIView? {
        subviews.last
    }
}
