//
//  ProfileInfoCell.swift
//  Primal
//
//  Created by Pavle D Stevanović on 8.6.23..
//

import Combine
import Nantes
import UIKit
import GenericJSON

protocol ProfileInfoCellDelegate: AnyObject {
    func followPressed(in cell: ProfileInfoCell)
    func qrPressed()
    func zapPressed()
    func editProfilePressed()
    func messagePressed()
    func linkPressed(_ url: URL?)
    func followersPressed()
    func followingPressed()
    func premiumPillPressed()
    func linkButtonPressed()
    func socialLinkPressed(_ url: URL)
    func manageSubscriptionPressed()
    
    func didSelectTab(_ tab: Int)
}

class ProfileCellNantesDelegate {
    weak var cell: ProfileInfoCell?
    init(cell: ProfileInfoCell) {
        self.cell = cell
    }
}

class ProfileInfoCell: UITableViewCell {
    let qrButton = CircleIconButton(icon: UIImage(named: "profileQR"))
    let messageButton = CircleIconButton(icon: UIImage(named: "profileMessage"))
    let linkButton = CircleIconButton(icon: UIImage(named: "linkIcon"))
    let followButton = BrightSmallButton(title: "follow").constrainToSize(width: 100)
    let unfollowButton = RoundedSmallButton(text: "unfollow").constrainToSize(width: 100)
    let editProfile = RoundedSmallButton(text: "edit profile")
    
    let followingLabel = UILabel()
    let followersLabel = UILabel()
    
    let primaryLabel = UILabel()
    let checkboxIcon = VerifiedView().constrainToSize(20)
    let followsYou = FollowsYouView()
    let premiumBadge = PremiumUserTitleView(height: 20, fontSize: 12)
    
    let secondaryLabel = UILabel()
    let descLabel = NantesLabel()
    let linkView = UILabel()
    let followedByView = FollowedByView()
    let socialLinksView = ProfileSocialLinksView()
    let subscriptionCard = ProfileSubscriptionCardView()
    
    private let infoStack = ProfileTabSelectionView(items: [
        ProfileTabItem(title: "Notes", icon: UIImage(systemName: "doc.text")),
        ProfileTabItem(title: "Replies", icon: UIImage(systemName: "arrowshape.turn.up.left")),
        ProfileTabItem(title: "Reads", icon: UIImage(systemName: "book")),
        ProfileTabItem(title: "Media", icon: UIImage(systemName: "photo.on.rectangle")),
        ProfileTabItem(title: "Subscribers", icon: UIImage(systemName: "person.2")),
        ProfileTabItem(title: "Paid", icon: UIImage(systemName: "creditcard"))
    ])
    
    weak var delegate: ProfileInfoCellDelegate?
    
    lazy var nantesDelegate = ProfileCellNantesDelegate(cell: self)
    
    var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(user: PrimalUser, parsedDescription: NSAttributedString, stats: NostrUserProfileInfo?, followedBy: [ParsedUser]?, followsUser: Bool, selectedTab: Int, delegate: ProfileInfoCellDelegate?) {
        self.delegate = delegate
        
        primaryLabel.text = user.firstIdentifier
        primaryLabel.isHidden = primaryLabel.text == user.npub
        
        followsYou.isHidden = !followsUser
        
        if CheckNip05Manager.instance.isVerified(user) {
            checkboxIcon.user = user
            
            secondaryLabel.isHidden = false
            secondaryLabel.text = user.parsedNip.replacingOccurrences(of: "primal", with: "crays")
        } else {
            checkboxIcon.isHidden = true
            secondaryLabel.isHidden = true
        }
        
        if let custom = PremiumCustomizationManager.instance.getPremiumInfo(pubkey: user.pubkey) {
            premiumBadge.titleLabel.text = custom.cohort_1.replacingOccurrences(of: "Primal", with: "Crays")
            premiumBadge.subtitleLabel.text = custom.cohort_2
            
            if custom.tier == "premium-legend" {
                if let custom = PremiumCustomizationManager.instance.getCustomization(pubkey: user.pubkey)?.theme {
                    premiumBadge.theme = custom
                    premiumBadge.isHidden = true
                } else {
                    premiumBadge.isHidden = true
                }
            } else if (custom.tier == "premium" && Date(timeIntervalSince1970: custom.expires_on ?? 0).timeIntervalSinceNow > 0) {
                premiumBadge.isHidden = false
                premiumBadge.theme = nil
            }
        } else {
            premiumBadge.isHidden = true
        }
        
        descLabel.attributedText = parsedDescription
        linkView.text = user.website.trimmingCharacters(in: .whitespaces)
        
        socialLinksView.update(with: socialLinkItems(from: user.userSocialLinks))
        subscriptionCard.configure(with: SubscriptionSettingsStore.shared.settings, isCurrentUser: user.isCurrentUser)
        
        if let stats {
            infoStack.isLoading = false
            followingLabel.attributedText = infoString(count: stats.follows, text: "following")
            followersLabel.attributedText = infoString(count: stats.followers, text: "followers")
        } else {
            followingLabel.attributedText = infoString(text: "following")
            followersLabel.attributedText = infoString(text: "followers")
            infoStack.isLoading = true
        }
        
        followedByView.setUsers(followedBy)
        followedByView.isHidden = followedBy?.isEmpty == true
        
        infoStack.set(selectedTab, animated: false)
        
        editProfile.isHidden = !user.isCurrentUser
        linkButton.isHidden = !user.isCurrentUser

        if user.isCurrentUser {
            followButton.isHidden = true
            unfollowButton.isHidden = true
        } else {
            updateFollowButton(FollowManager.instance.isFollowing(user.pubkey))
        }
        
        contentView.backgroundColor = .background2
        primaryLabel.textColor = .foreground
        secondaryLabel.textColor = .foreground3
        descLabel.textColor = .foreground
        descLabel.linkAttributes = [
            .foregroundColor: UIColor.accent2
        ]
        linkView.textColor = .accent2
    }
    
    func updateFollowButton(_ isFollowing: Bool) {
        followButton.isHidden = isFollowing
        unfollowButton.isHidden = !isFollowing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func infoString(count: Int? = nil, text: String) -> NSAttributedString {
        guard let count else {
            return NSAttributedString(string: "   ", attributes: [
                .font: UIFont.appFont(withSize: 14, weight: .bold),
                .foregroundColor: UIColor.foreground
            ])
        }
        
        let countString = "\(count.localized()) "
        
        let mutable = NSMutableAttributedString(string: countString, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .bold),
            .foregroundColor: UIColor.foreground
        ])
        
        mutable.append(.init(string: text, attributes: [
            .font: UIFont.appFont(withSize: 14, weight: .regular),
            .foregroundColor: UIColor.foreground3
        ]))
        
        return mutable
    }
}

extension ProfileCellNantesDelegate: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        cell?.delegate?.linkPressed(link)
    }
}

private extension ProfileInfoCell {
    func setup() {
        let actionStack = UIStackView(arrangedSubviews: [SpacerView(width: 400, priority: .defaultLow), qrButton, linkButton, messageButton, followButton, unfollowButton, editProfile])
        actionStack.spacing = 8
        actionStack.alignment = .bottom
        
        let primaryStack = UIStackView(arrangedSubviews: [primaryLabel, checkboxIcon, premiumBadge, UIView()])
        primaryStack.setCustomSpacing(4, after: primaryLabel)
        primaryStack.setCustomSpacing(8, after: checkboxIcon)
        primaryStack.alignment = .center
        
        primaryLabel.font = .appFont(withSize: 20, weight: .bold)
        primaryLabel.adjustsFontSizeToFitWidth = true
        
        let followStack = UIStackView([followingLabel, followersLabel, followsYou])
        followStack.spacing = 8
        followingLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        followsYou.isHidden = true
        
        secondaryLabel.font = .appFont(withSize: 14, weight: .regular)
        
        descLabel.font = .appFont(withSize: 14, weight: .regular)
        descLabel.numberOfLines = 0
        
        socialLinksView.didSelect = { [weak self] url in
            self?.delegate?.socialLinkPressed(url)
        }
        subscriptionCard.onManageTapped = { [weak self] in
            self?.delegate?.manageSubscriptionPressed()
        }
        
        let mainStack = UIStackView(arrangedSubviews: [actionStack, socialLinksView, primaryStack, secondaryLabel, followStack, descLabel, linkView, followedByView, subscriptionCard, infoStack])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.setCustomSpacing(14, after: actionStack)
        mainStack.setCustomSpacing(12, after: socialLinksView)
        mainStack.setCustomSpacing(8, after: primaryStack)
        mainStack.setCustomSpacing(12, after: secondaryLabel)
        mainStack.setCustomSpacing(10, after: followStack)
        mainStack.setCustomSpacing(8, after: descLabel)
        mainStack.setCustomSpacing(10, after: linkView)
        mainStack.setCustomSpacing(10, after: followedByView)
        mainStack.setCustomSpacing(16, after: subscriptionCard)
        
        infoStack.pinToSuperview(edges: .horizontal)
        
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        let bot = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bot.priority = .defaultHigh
        bot.isActive = true
        
        descLabel.enabledTextCheckingTypes = .allSystemTypes
        descLabel.delegate = nantesDelegate
        
        linkView.font = .appFont(withSize: 14, weight: .regular)
        linkView.isUserInteractionEnabled = true
        linkView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.linkPressed(nil)
        }))
        
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        unfollowButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        
        followedByView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.followersPressed()
        }))
        
        qrButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.qrPressed()
        }), for: .touchUpInside)
        
        linkButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.linkButtonPressed()
        }), for: .touchUpInside)
        
        editProfile.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.editProfilePressed()
        }), for: .touchUpInside)
        messageButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.messagePressed()
        }), for: .touchUpInside)
        
        infoStack.$selectedTab.removeDuplicates().dropFirst().sink { [weak self] tab in
            self?.delegate?.didSelectTab(tab)
        }
        .store(in: &cancellables)
        
        premiumBadge.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.premiumPillPressed()
        }))
        
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.delegate?.followingPressed() }))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in self?.delegate?.followersPressed() }))
    }
    
    func socialLinkItems(from links: UserSocialLinks?) -> [ProfileSocialLinkItem] {
        guard let links else { return [] }
        return SocialLinkType.allCases.compactMap { type in
            guard
                let value = links.value(for: type),
                let url = type.url(from: value)
            else { return nil }
            return ProfileSocialLinkItem(type: type, url: url)
        }
    }
    
    @objc func followPressed() {
        delegate?.followPressed(in: self)
    }
}

final class FollowsYouView: UIView {
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 8).centerToSuperview()
        label.font = .appFont(withSize: 14, weight: .regular)
        label.text = "follows you"
        
        constrainToSize(height: 22)
        
        layer.cornerRadius = 4
        
        label.textColor = .foreground3
        backgroundColor = .background3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
