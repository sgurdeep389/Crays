//
//  NewPostViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.5.23..
//

import Combine
import UIKit
import Kingfisher

extension UIButton.Configuration {
    static func capsuleBackground3(text: String, font: UIFont = UIFont.appFont(withSize: 14, weight: .regular)) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.attributedTitle = .init(text, attributes: .init([.font: font]))
        config.baseForegroundColor = .foreground
        config.baseBackgroundColor = .background3
        return config
    }
}

class NewPostViewController: UIViewController {
    let textView = UITextView()
    let imageView = UserImageView(height: 52)
    
    let usersTableView = UITableView()
    let imagesCollectionView = PostingImageCollectionView()
    
    enum Visibility: Int, CaseIterable {
        case `public`
        case subscribers
        case ppv
        
        var title: String {
            switch self {
            case .public: return "Public"
            case .subscribers: return "Subscribers only"
            case .ppv: return "PPV"
            }
        }
        
        var description: String {
            switch self {
            case .public: return ""
            case .subscribers: return "Visible only to your paying subscribers."
            case .ppv: return "Followers see a locked preview. Max 50,000 sats per post."
            }
        }
    }
    
    private var selectedVisibility: Visibility = .public {
        didSet { updateVisibilityUI() }
    }
    
    let imageButton = UIButton()
    let cameraButton = UIButton()
    let atButton = UIButton()
    let clearButton = UIButton(configuration: .capsuleBackground3(text: "Clear")).constrainToSize(width: 80, height: 28)
    lazy var bottomStack = UIStackView(arrangedSubviews: [imageButton, cameraButton, atButton, UIView(), clearButton])
    
    private let visibilityContainer = UIView()
    private let visibilityControl = UISegmentedControl(items: Visibility.allCases.map { $0.title })
    private let visibilityDescription = UILabel()
    private let ppvContainer = UIView()
    private let ppvField = UITextField()
    
    lazy var postButton = SmallPostButton(title: "Post")
    
    lazy var manager = PostingTextViewManager(textView: textView, usersTable: usersTableView, replyId: replyToPost?.universalID, replyingTo: replyToPost)
    
    private var cancellables: Set<AnyCancellable> = []
    
    var replyToPost: PrimalFeedPost?
    
    var onPost: (() -> Void)?
    
    init(replyToPost: PrimalFeedPost? = nil, onPost: (() -> Void)? = nil) {
        self.replyToPost = replyToPost
        self.onPost = onPost
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.becomeFirstResponder()
        textView.selectedRange = .init(location: 0, length: 0)
    }
}

private extension NewPostViewController {
    @objc func postButtonPressed() {
        if manager.didUploadFail {
            manager.restartFailedUploads()
            return
        }
        
        if manager.isUploadingImages {
            return
        }
        
        let text = manager.postingText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !text.isEmpty else {
            showErrorMessage(title: "Please Enter Text", "Text cannot be empty")
            return
        }
        
        let onPost = self.onPost
        manager.post { success, _ in
            if success {
                onPost?()
            }
        }
        dismiss(animated: true)
    }
    
    @objc func galleryButtonPressed() {
        ImagePickerManager(self, mode: .gallery, allowVideo: true) { [weak self] result in
            self?.manager.processSelectedAsset(result)
        }
    }
    
    @objc func cameraButtonPressed() {
        ImagePickerManager(self, mode: .camera) { [weak self] result in
            self?.manager.processSelectedAsset(result)
        }
    }
    
    func setup() {
        presentationController?.delegate = self
        view.backgroundColor = .background2
        
        let cancel = CancelButton()
        let topStack = UIStackView(arrangedSubviews: [cancel, UIView(), postButton])
        postButton.constrainToSize(width: 88)
        cancel.constrainToSize(width: 88, height: 32)
        
        topStack.alignment = .center
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let imageParent = UIView()
        imageParent.addSubview(imageView)
        imageView.pinToSuperview(edges: [.horizontal, .top])
                
        let contentStack = UIStackView(arrangedSubviews: [imageParent, textView])
        contentStack.spacing = 10
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        
        imageView.layer.cornerRadius = 26
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageButton.setImage(UIImage(named: "ImageIcon"), for: .normal)
        cameraButton.setImage(UIImage(named: "CameraIcon"), for: .normal)
        atButton.setImage(UIImage(named: "AtIcon"), for: .normal)
        [imageButton, cameraButton, atButton].forEach {
            $0.constrainToSize(44)
            $0.tintColor = .accent
        }
        
        setupVisibilityControls()
        
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        bottomStack.spacing = 12
        bottomStack.alignment = .center
        
        let border = SpacerView(height: 1, priority: .required)
        border.backgroundColor = .background3
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, contentStack, visibilityContainer, visibilityDescription, ppvContainer, imagesCollectionView, border, usersTableView, bottomStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.horizontal, .top])
        
        mainStack.setCustomSpacing(12, after: contentStack)
        mainStack.setCustomSpacing(6, after: visibilityContainer)
        mainStack.setCustomSpacing(16, after: visibilityDescription)
        mainStack.setCustomSpacing(16, after: ppvContainer)
        mainStack.setCustomSpacing(16, after: imagesCollectionView)
        
        imagesCollectionView.imageDelegate = manager
        imagesCollectionView.isHidden = true
        imagesCollectionView.backgroundColor = .background2
        
        let keyboardConstraint = mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        keyboardConstraint.priority = .defaultHigh // Constraint breaks when dismmising the view controller (keyboard is showing)
        
        NSLayoutConstraint.activate([
            keyboardConstraint,
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),
        ])
        
        cancel.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            if manager.isPosting {
                manager.askToDeleteDraft(self) { [weak self] delete in
                    if !delete {
                        self?.dismiss(animated: true)
                    }
                }
                return
            }
            
            manager.askToSaveThenDismiss(self)
        }), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        atButton.addTarget(manager, action: #selector(PostingTextViewManager.atButtonPressed), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        clearButton.addAction(.init(handler: { [weak self] _ in
            if self?.manager.postingText.isEmpty == true  { return }
            
            let alert = UIAlertController(title: "Are you sure?", message: "Clear everything?", preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Clear", style: .destructive, handler: { _ in
                self?.manager.reset()
            }))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
        
        textView.tintColor = .accent
        
        setupBindings()
    }
    
    func setupBindings() {        
        IdentityManager.instance.$parsedUser.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let self, let user else { return }
            
            self.imageView.setUserImage(user)
        }
        .store(in: &cancellables)
        
        manager.$users.receive(on: DispatchQueue.main).sink { [weak self] users in
            guard let self else { return }
            self.bottomStack.isHidden = !users.isEmpty
            self.usersTableView.isHidden = users.isEmpty
            self.manager.usersHeightConstraint.constant = CGFloat(users.count) * 60
            UIView.animate(withDuration: 0.3) {
                self.view.layoutSubviews()
                self.textView.scrollToCursorPosition()
            } completion: { _ in
                self.usersTableView.reloadData()
                self.textView.scrollToCursorPosition()
            }
            self.usersTableView.reloadData()
        }
        .store(in: &cancellables)
        
        manager.$postButtonEnabledState.assign(to: \.isEnabled, on: postButton).store(in: &cancellables)
        manager.$postButtonTitle.sink { [postButton] title in
            postButton.setTitle(title, for: .normal)
        }
        .store(in: &cancellables)
        
        manager.$isPosting.map({ !$0 }).assign(to: \.isUserInteractionEnabled, on: bottomStack).store(in: &cancellables)
        manager.$isPosting.map({ !$0 }).assign(to: \.isUserInteractionEnabled, on: visibilityControl).store(in: &cancellables)
        
        Publishers.CombineLatest(
            manager.$users.map({ $0.isEmpty }).removeDuplicates(),
            manager.$media
        ).receive(on: DispatchQueue.main).sink { [weak self] isUsersEmpty, images in
            guard let self else { return }
            self.imagesCollectionView.imageResources = images
            
            self.imagesCollectionView.isHidden = images.isEmpty || !isUsersEmpty
        }
        .store(in: &cancellables)
    }
    
    func setupVisibilityControls() {
        visibilityContainer.backgroundColor = .background2
        visibilityContainer.layer.cornerRadius = 22
        visibilityContainer.layer.borderWidth = 1
        visibilityContainer.layer.borderColor = UIColor.background3.cgColor
        visibilityContainer.translatesAutoresizingMaskIntoConstraints = false
        visibilityContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        
        visibilityControl.selectedSegmentIndex = selectedVisibility.rawValue
        visibilityControl.translatesAutoresizingMaskIntoConstraints = false
        visibilityControl.backgroundColor = .clear
        visibilityControl.selectedSegmentTintColor = UIColor.accent.withAlphaComponent(0.15)
        visibilityControl.setTitleTextAttributes([
            .font: UIFont.appFont(withSize: 15, weight: .semibold),
            .foregroundColor: UIColor.foreground3
        ], for: .normal)
        visibilityControl.setTitleTextAttributes([
            .font: UIFont.appFont(withSize: 15, weight: .semibold),
            .foregroundColor: UIColor.accent
        ], for: .selected)
        visibilityControl.addTarget(self, action: #selector(visibilityChanged(_:)), for: .valueChanged)
        
        visibilityContainer.addSubview(visibilityControl)
        NSLayoutConstraint.activate([
            visibilityControl.topAnchor.constraint(equalTo: visibilityContainer.topAnchor, constant: 12),
            visibilityControl.bottomAnchor.constraint(equalTo: visibilityContainer.bottomAnchor, constant: -12),
            visibilityControl.leadingAnchor.constraint(equalTo: visibilityContainer.leadingAnchor, constant: 12),
            visibilityControl.trailingAnchor.constraint(equalTo: visibilityContainer.trailingAnchor, constant: -12),
            visibilityControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        visibilityDescription.font = .appFont(withSize: 13, weight: .regular)
        visibilityDescription.textColor = .foreground3
        visibilityDescription.numberOfLines = 0
        visibilityDescription.textAlignment = .center
        visibilityDescription.setContentCompressionResistancePriority(.required, for: .vertical)
        visibilityDescription.setContentHuggingPriority(.required, for: .vertical)
        
        ppvContainer.layer.cornerRadius = 18
        ppvContainer.layer.borderWidth = 1
        ppvContainer.layer.borderColor = UIColor.background3.cgColor
        ppvContainer.backgroundColor = .background
        ppvContainer.isHidden = true
        
        let priceLabel = UILabel()
        priceLabel.font = .appFont(withSize: 15, weight: .semibold)
        priceLabel.textColor = .foreground
        priceLabel.text = "Unlock price (sats)"
        
        ppvField.keyboardType = .numberPad
        ppvField.font = .appFont(withSize: 18, weight: .medium)
        ppvField.textColor = .foreground
        ppvField.tintColor = .accent
        ppvField.attributedPlaceholder = NSAttributedString(string: "5,000", attributes: [
            .foregroundColor: UIColor.foreground4,
            .font: UIFont.appFont(withSize: 18, weight: .medium)
        ])
        
        let fieldContainer = UIView()
        fieldContainer.layer.cornerRadius = 14
        fieldContainer.layer.borderWidth = 1
        fieldContainer.layer.borderColor = UIColor.background4.cgColor
        fieldContainer.backgroundColor = .background2
        fieldContainer.addSubview(ppvField)
        ppvField.pinToSuperview(edges: [.leading, .trailing], padding: 12)
        ppvField.pinToSuperview(edges: [.top, .bottom], padding: 10)
        
        let helperLabel = UILabel()
        helperLabel.font = .appFont(withSize: 12, weight: .regular)
        helperLabel.textColor = .foreground4
        helperLabel.numberOfLines = 0
        helperLabel.text = Visibility.ppv.description
        
        let ppvStack = UIStackView(arrangedSubviews: [priceLabel, fieldContainer, helperLabel])
        ppvStack.axis = .vertical
        ppvStack.spacing = 8
        ppvStack.isLayoutMarginsRelativeArrangement = true
        ppvStack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        ppvContainer.addSubview(ppvStack)
        ppvStack.pinToSuperview()
        
        updateVisibilityUI()
    }
    
    func updateVisibilityUI() {
        visibilityControl.selectedSegmentIndex = selectedVisibility.rawValue
        
        let description = selectedVisibility.description
        visibilityDescription.text = description
        visibilityDescription.isHidden = description.isEmpty
        ppvContainer.isHidden = selectedVisibility != .ppv
    }
    
    @objc func visibilityChanged(_ sender: UISegmentedControl) {
        guard let mode = Visibility(rawValue: sender.selectedSegmentIndex) else { return }
        selectedVisibility = mode
    }
}

extension NewPostViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        manager.askToSaveThenDismiss(self)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
}
