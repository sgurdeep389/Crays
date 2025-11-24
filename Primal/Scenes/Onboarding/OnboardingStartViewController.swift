//
//  OnboardingStartViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import UIKit
import SafariServices
import Kingfisher

final class OnboardingMainButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    init(_ title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        titleLabel?.font = .appFont(withSize: 18, weight: .semibold)
        backgroundColor = .black.withAlphaComponent(0.81)
        layer.cornerRadius = 28
        constrainToSize(height: 56)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class OnboardingStartViewController: UIViewController, OnboardingViewController {
    let titleLabel = UILabel()
    let backButton: UIButton = .init()
    
    let termsBothLines = TermsAndConditionsView(whiteOverride: true)
    
    let signupButton = OnboardingMainButton("Create Account")
    let signinButton = OnboardingMainButton("Sign In")
    let redeemCodeButton = OnboardingMainButton("Redeem Code")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    @objc func signupPressed() {
        onboardingParent?.pushViewController(OnboardingDisplayNameController(), animated: true)
    }
    
    @objc func signinPressed() {
        onboardingParent?.pushViewController(OnboardingSigninController(), animated: true)
    }
}

private extension OnboardingStartViewController {
    func setup() {
        let container = UIView()
        container.backgroundColor = .white
        view.addSubview(container)
        view.backgroundColor = .white

        // ✅ Configure the title label
        titleLabel.text = "Welcome to Crays"
        titleLabel.font = .appFont(withSize: 24, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        container.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 150),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        // ✅ Logo setup
        let logo = UIImageView(image: .onboardingLogo)
        let logoParent = UIView()
        logoParent.addSubview(logo)
        logo.centerToSuperview().pinToSuperview(edges: .vertical)

        // ✅ Buttons stack
        let contentStack = UIStackView(arrangedSubviews: [
            signinButton,       SpacerView(height: 10, priority: .defaultHigh),
            signupButton,       SpacerView(height: 10, priority: .defaultHigh),
            // redeemCodeButton, SpacerView(height: 18, priority: .defaultHigh),
            termsBothLines
        ])
        contentStack.axis = .vertical

        container.addSubview(contentStack)
        contentStack
            .pinToSuperview(edges: .horizontal, padding: 35)
            .pinToSuperview(edges: .bottom, padding: 12, safeArea: true)

        // ✅ Button actions
        signupButton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinPressed), for: .touchUpInside)
        redeemCodeButton.addAction(.init(handler: { [weak self] _ in
            self?.onboardingParent?.pushViewController(OnboardingScanCodeController(), animated: true)
        }), for: .touchUpInside)

        // ✅ Container sizing / scaling
        container.constrainToSize(width: 375, height: 800)
        container.centerToSuperview(axis: .horizontal)
        let centerYC = container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerYC.priority = .defaultHigh
        centerYC.isActive = true
        container.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        let scale = UIScreen.main.bounds.width / 375
        container.transform = .init(scaleX: scale, y: scale)
    }
}

