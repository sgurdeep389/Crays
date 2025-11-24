//
//  WalletViewController.swift
//  Crays
//
//  Created by Gurdeep Singh  on 22/11/25.
//

import UIKit

class WalletViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.spacing = 24
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    private let heroIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "wallet.pass"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let heroTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your Lightning Wallet"
        lbl.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let heroSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.text =
        """
        Create a new wallet or import an existing one to start sending and receiving Lightning payments instantly.
        """
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let createCard = ActionCardView(
        icon: UIImage(systemName: "plus.circle"),
        title: "Create New Wallet",
        description: "Generate a new wallet with a secure recovery phrase"
    )
    
    private let importCard = ActionCardView(
        icon: UIImage(systemName: "arrow.down.doc"),
        title: "Import Wallet",
        description: "Restore your wallet using a recovery phrase"
    )
    
    private let securityStack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.spacing = 12
        st.alignment = .center
        st.translatesAutoresizingMaskIntoConstraints = false
        return st
    }()
    
    private let shieldIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "shield.checkerboard"))
        iv.tintColor = .systemGreen
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let securityLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your keys, your Bitcoin. All data is stored securely on your device."
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Wallet"
        
        setupLayout()
        setupActions()
        checkWalletRedirect()
    }
    
    
    // MARK: - Layout
    
    private func setupLayout() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Add hero section
        contentStack.addArrangedSubview(heroIcon)
        contentStack.addArrangedSubview(heroTitle)
        contentStack.addArrangedSubview(heroSubtitle)
        
        heroIcon.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Add create card
        contentStack.addArrangedSubview(createCard)
        createCard.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Add import card
        contentStack.addArrangedSubview(importCard)
        importCard.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Security stack
        securityStack.addArrangedSubview(shieldIcon)
        securityStack.addArrangedSubview(securityLabel)
        shieldIcon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        shieldIcon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        contentStack.addArrangedSubview(securityStack)
    }
    
    
    // MARK: - Button Actions
    
    private func setupActions() {
        
        createCard.onTap = { [weak self] in
            let vc = CreateWalletViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        importCard.onTap = { [weak self] in
            let vc = ImportWalletViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: - Wallet Redirect
    
    private func checkWalletRedirect() {
//        if WalletManager.shared.getSavedMnemonic() != nil {
//            // Already have a wallet → go to dashboard
//            let dashboard = DashboardViewController()
//            navigationController?.setViewControllers([dashboard], animated: true)
//        }
    }
}

