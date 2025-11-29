import UIKit

final class ProfileSubscriptionCardView: UIView {
    private let container = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let manageButton = UIButton(type: .system)
    private let statsLabel = UILabel()
    
    var onManageTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 16
        container.backgroundColor = .background2
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.background4.cgColor
        
        iconContainer.backgroundColor = UIColor.accent2.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 16
        iconContainer.constrainToSize(40)
        
        iconImageView.image = UIImage(systemName: "bolt.fill")
        iconImageView.tintColor = .accent
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)
        iconImageView.constrainToSize(18).centerToSuperview()
        
        titleLabel.font = .appFont(withSize: 18, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.numberOfLines = 2
        
        subtitleLabel.font = .appFont(withSize: 13, weight: .regular)
        subtitleLabel.textColor = .foreground4
        subtitleLabel.text = "Lightning payments only"
        
        manageButton.setTitle("Manage", for: .normal)
        manageButton.titleLabel?.font = .appFont(withSize: 16, weight: .semibold)
        manageButton.backgroundColor = .foreground
        manageButton.setTitleColor(.background, for: .normal)
        manageButton.layer.cornerRadius = 12
        manageButton.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        manageButton.addAction(.init(handler: { [weak self] _ in
            self?.onManageTapped?()
        }), for: .touchUpInside)
        
        statsLabel.font = .appFont(withSize: 14, weight: .regular)
        statsLabel.textColor = .foreground4
        statsLabel.numberOfLines = 1
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        
        let leadingStack = UIStackView(arrangedSubviews: [iconContainer, textStack])
        leadingStack.axis = .horizontal
        leadingStack.alignment = .center
        leadingStack.spacing = 12
        
        let headerStack = UIStackView(arrangedSubviews: [leadingStack, manageButton])
        headerStack.alignment = .center
        headerStack.spacing = 12
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, statsLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        
        container.addSubview(mainStack)
        addSubview(container)
        
        container.pinToSuperview()
        mainStack.pinToSuperview(edges: .all, padding: 16)
    }
    
    func configure(with settings: SubscriptionSettings?, isCurrentUser: Bool) {
        guard isCurrentUser, let settings else {
            isHidden = true
            return
        }
        
        isHidden = false
        titleLabel.text = "Subscriptions from \(settings.monthlyPrice.localized()) sats / month"
        let activeText = "\(settings.subscribersActive.localized()) active"
        let expiringText = "\(settings.subscribersExpiringSoon.localized()) expiring soon"
        let lapsedText = "\(settings.subscribersLapsed.localized()) lapsed"
        statsLabel.text = "\(activeText) · \(expiringText) · \(lapsedText)"
    }
}

