
import UIKit
import Kingfisher

final class SocialLinkViewController: UIViewController, Themeable {

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let contentView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        return stack
    }()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 30
        iv.clipsToBounds = true
        iv.constrainToSize(60)
        return iv
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        return label
    }()

    private let userIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "Edit your social links"
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "Connect with people everywhere. Your social links will display on your public profile."
        return label
    }()

    private let instagramField = SocialInput(type: .instagram)
    private let xField = SocialInput(type: .x)
    private let youtubeField = SocialInput(type: .youtube)
    private let snapchatField = SocialInput(type: .snapchat)
    private let facebookField = SocialInput(type: .facebook)
    private let tiktokField = SocialInput(type: .tiktok)
    
    private lazy var socialInputPairs: [(type: SocialLinkType, input: SocialInput)] = [
        (.x, xField),
        (.instagram, instagramField),
        (.youtube, youtubeField),
        (.snapchat, snapchatField),
        (.facebook, facebookField),
        (.tiktok, tiktokField)
    ]

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Links", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    var profile: PrimalUser
    var checkedLud16: String

    init(profile: PrimalUser) {
        self.profile = profile
        self.checkedLud16 = profile.lud16
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateUserData()
        setupLayout()
        populateSocialInputs()
        updateTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }

    private func setupLayout() {
        navigationItem.leftBarButtonItem = customBackButton

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let profileStack = UIStackView(arrangedSubviews: [profileImageView, usernameLabel, userIdLabel])
        profileStack.axis = .vertical
        profileStack.spacing = 4
        profileStack.alignment = .center

        contentView.addArrangedSubview(profileStack)
        contentView.addArrangedSubview(headingLabel)
        contentView.addArrangedSubview(subtitleLabel)

        socialInputPairs.forEach { contentView.addArrangedSubview($0.input) }
        
        saveButton.addTarget(self, action: #selector(btnSave), for: .touchUpInside)
    }
    
    @objc private func btnSave() {
        view.endEditing(true)
        
        let values = socialInputPairs.reduce(into: [String: String]()) { result, entry in
            if let text = entry.input.text?.nilIfEmpty {
                result[entry.type.storageKey] = text
            }
        }
        
        let updatedLinks = UserSocialLinks(
            x: values[SocialLinkType.x.storageKey],
            instagram: values[SocialLinkType.instagram.storageKey],
            youtube: values[SocialLinkType.youtube.storageKey],
            snapchat: values[SocialLinkType.snapchat.storageKey],
            facebook: values[SocialLinkType.facebook.storageKey],
            tiktok: values[SocialLinkType.tiktok.storageKey]
        )
        
        var metadata = profile.profileData
        metadata.social_links = values.isEmpty ? nil : values
        
        saveButton.isEnabled = false
        IdentityManager.instance.updateProfile(metadata) { [weak self] success in
            DispatchQueue.main.async {
                guard let self else { return }
                self.saveButton.isEnabled = true
                
                guard success else {
                    self.view.showToast("Unable to save social links", icon: UIImage(named: "toastX"), extraPadding: 0)
                    return
                }
                
                self.profile.userSocialLinks = values.isEmpty ? nil : updatedLinks
                if var parsedUser = IdentityManager.instance.parsedUser {
                    parsedUser.data.userSocialLinks = self.profile.userSocialLinks
                    IdentityManager.instance.parsedUser = parsedUser
                }
                
        if let tab = self.mainTabBarController {
            tab.showToast("Social links updated")
        } else {
            self.view.showToast("Social links updated", extraPadding: 0)
        }

        self.navigationController?.popViewController(animated: true)
            }
        }
    }
    private func populateUserData() {
        let displayName = profile.displayName.isEmpty ? profile.name : profile.displayName
        usernameLabel.text = displayName.isEmpty ? "@\(profile.name)" : displayName
        userIdLabel.text = truncatedIdentifier(from: profile.pubkey)

        if let imageURL = URL(string: profile.picture), !profile.picture.isEmpty {
            profileImageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "Profile"))
        } else {
            profileImageView.image = UIImage(named: "Profile")
        }
    }
    
    private func populateSocialInputs() {
        guard let links = profile.userSocialLinks else { return }
        for (type, input) in socialInputPairs {
            input.text = links.value(for: type)
        }
    }

    private func truncatedIdentifier(from value: String) -> String {
        guard value.count > 12 else { return value }
        let prefix = value.prefix(6)
        let suffix = value.suffix(6)
        return "\(prefix)...\(suffix)"
    }

    func updateTheme() {
        view.backgroundColor = .background
        scrollView.backgroundColor = .clear

        usernameLabel.textColor = .foreground
        userIdLabel.textColor = .foreground4
        headingLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground3
        saveButton.backgroundColor = .accent
        saveButton.setTitleColor(.white, for: .normal)

        updateThemeForInputs()
    }

    private func updateThemeForInputs() {
        socialInputPairs.forEach { $0.input.updateTheme() }
    }
}


// MARK: - SocialInput UI
class SocialInput: UIView, Themeable {

    private let iconView = UIImageView()
    private let textField = UITextField()
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    init(icon: UIImage?, placeholder: String) {
        super.init(frame: .zero)
        setup(icon: icon, placeholder: placeholder)
    }
    
    convenience init(type: SocialLinkType) {
        self.init(icon: UIImage(named: type.iconName), placeholder: type.placeholder)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(icon: UIImage?, placeholder: String) {
        translatesAutoresizingMaskIntoConstraints = false

        iconView.image = icon
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 22).isActive = true

        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 15)
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.keyboardType = .URL

        let hStack = UIStackView(arrangedSubviews: [iconView, textField])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center

        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            heightAnchor.constraint(equalToConstant: 52)
        ])

        layer.cornerRadius = 14
        layer.borderWidth = 1
    }

    func updateTheme() {
        backgroundColor = .background2
        layer.borderColor = UIColor.background4.cgColor
        if iconView.image?.renderingMode == .alwaysTemplate {
            iconView.tintColor = .foreground4
        }
        textField.textColor = .foreground
        textField.tintColor = .foreground
        textField.keyboardAppearance = Theme.current.userInterfaceStyle == .dark ? .dark : .light
    }
}
