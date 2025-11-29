//
//  ActionCardView.swift
//  Crays
//
//  Created by Gurdeep Singh  on 22/11/25.
//

import Foundation
import UIKit

class WalletManager1 {
    
    static let shared = WalletManager1()
    private init() {}
    
    func getSavedMnemonic() -> String? {
        UserDefaults.standard.string(forKey: "mnemonic")
    }
    
    func saveMnemonic(_ mnemonic: String) {
        UserDefaults.standard.setValue(mnemonic, forKey: "mnemonic")
    }
    
    func saveLightningAddress(_ mnemonic: String) {
        UserDefaults.standard.setValue(mnemonic, forKey: "LightningAddress")
    }
    
    func getSavedLightningAddress() -> String? {
        UserDefaults.standard.string(forKey: "LightningAddress")
    }
    
}


class ActionCardView: UIView {
    
    var onTap: (() -> Void)?
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let arrowIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .gray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    // MARK: - Init
    
    init(icon: UIImage?, title: String, description: String) {
        super.init(frame: .zero)
        self.iconView.image = icon
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        
        setupView()
        setupTap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = true
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconView)
        addSubview(textStack)
        addSubview(arrowIcon)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIcon.widthAnchor.constraint(equalToConstant: 18),
            arrowIcon.heightAnchor.constraint(equalToConstant: 18),
            
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: arrowIcon.leadingAnchor, constant: -14),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}

