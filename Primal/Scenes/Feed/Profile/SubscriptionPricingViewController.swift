import UIKit

final class SubscriptionPricingViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let monthlyPriceField = UITextField()
    private let monthlyNoteLabel = UILabel()
    private let approxUsdLabel = UILabel()
    
    private var bundleRows: [BundleRow] = []
    
    private let subscribersSection = SubscriptionStatsSection(title: "Subscribers", buttonTitle: "View all subscribers")
    private let earningsSection = EarningsSection()
    
    private var settings: SubscriptionSettings
    
    init(settings: SubscriptionSettings = SubscriptionSettingsStore.shared.settings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        populateFields()
        updateComputedValues()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    private func setupView() {
        view.backgroundColor = .background
        title = "Subscriptions & Pricing"
        navigationItem.leftBarButtonItem = customBackButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
        ])
        
        contentStack.addArrangedSubview(makeMonthlyPriceSection())
        contentStack.addArrangedSubview(makeBundlesSection())
        contentStack.addArrangedSubview(subscribersSection)
        contentStack.addArrangedSubview(earningsSection)
    }
    
    private func makeMonthlyPriceSection() -> UIView {
        let card = makeCardContainer()
        
        let title = UILabel()
        title.font = .appFont(withSize: 16, weight: .semibold)
        title.text = "Monthly price (Lightning)"
        title.textColor = .foreground
        
        monthlyPriceField.keyboardType = .numberPad
        monthlyPriceField.borderStyle = .roundedRect
        monthlyPriceField.font = .appFont(withSize: 18, weight: .regular)
        monthlyPriceField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        monthlyNoteLabel.font = .appFont(withSize: 13, weight: .regular)
        monthlyNoteLabel.textColor = .foreground4
        monthlyNoteLabel.text = "Min 5,000 sats · Max 500,000 sats"
        
        approxUsdLabel.font = .appFont(withSize: 13, weight: .regular)
        approxUsdLabel.textColor = .foreground4
        
        let stack = UIStackView(arrangedSubviews: [title, monthlyPriceField, monthlyNoteLabel, approxUsdLabel])
        stack.axis = .vertical
        stack.spacing = 10
        
        card.addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 16)
        return card
    }
    
    private func makeBundlesSection() -> UIView {
        let card = makeCardContainer()
        
        let title = UILabel()
        title.font = .appFont(withSize: 16, weight: .semibold)
        title.text = "Bundles & promotions"
        title.textColor = .foreground
        
        let bundlesStack = UIStackView()
        bundlesStack.axis = .vertical
        bundlesStack.spacing = 16
        
        let bundleConfigs: [(String, Int)] = [
            ("3 month bundle", 3),
            ("6 month bundle", 6),
            ("12 month bundle", 12)
        ]
        
        bundleRows = bundleConfigs.map { config in
            let row = BundleRow(months: config.1)
            row.titleLabel.text = config.0
            row.discountField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            bundlesStack.addArrangedSubview(row.container)
            return row
        }
        
        let discountsButton = UIButton(type: .system)
        discountsButton.setTitle("Manage time-limited discounts", for: .normal)
        discountsButton.setTitleColor(.accent, for: .normal)
        discountsButton.titleLabel?.font = .appFont(withSize: 14, weight: .semibold)
        
        let stack = UIStackView(arrangedSubviews: [title, bundlesStack, discountsButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        card.addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 16)
        return card
    }
    
    private func populateFields() {
        monthlyPriceField.text = "\(settings.monthlyPrice)"
        
        for row in bundleRows {
            row.discountField.text = "\(settings.discount(for: row.months))"
        }
        
        subscribersSection.update(active: settings.subscribersActive, expiring: settings.subscribersExpiringSoon, lapsed: settings.subscribersLapsed)
        earningsSection.update(settings: settings)
    }
    
    private func updateComputedValues() {
        let satsValue = Int(monthlyPriceField.text?.trimmed ?? "") ?? 0
        let usdValue = Double(satsValue).satToUSD
        approxUsdLabel.text = satsValue == 0 ? "≈ $0.00" : "≈ $\(usdValue.nDecimalPoints(n: 2))"
        
        for row in bundleRows {
            let discount = Int(row.discountField.text?.trimmed ?? "") ?? 0
            var previewSettings = settings
            previewSettings.monthlyPrice = satsValue == 0 ? settings.monthlyPrice : satsValue
            previewSettings.setDiscount(discount, for: row.months)
            let price = previewSettings.bundlePrice(for: row.months)
            row.priceLabel.text = "\(price.localized()) sats"
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateComputedValues()
    }
    
    @objc private func saveTapped() {
        guard let priceValue = Int(monthlyPriceField.text?.trimmed ?? ""), priceValue >= 5_000, priceValue <= 500_000 else {
            view.showToast("Monthly price must be between 5k and 500k", icon: UIImage(named: "toastX"), extraPadding: 0)
            return
        }
        
        SubscriptionSettingsStore.shared.update { settings in
            settings.monthlyPrice = priceValue
            for row in self.bundleRows {
                let value = Int(row.discountField.text?.trimmed ?? "") ?? 0
                settings.setDiscount(value, for: row.months)
            }
        }
        
        view.showToast("Subscription settings saved", extraPadding: 0)
        navigationController?.popViewController(animated: true)
    }
    
    private func makeCardContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .background2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.background4.cgColor
        return view
    }
}

private final class BundleRow {
    let months: Int
    let container = UIView()
    let titleLabel = UILabel()
    let discountField = UITextField()
    let priceLabel = UILabel()
    
    init(months: Int) {
        self.months = months
        setup()
    }
    
    private func setup() {
        titleLabel.font = .appFont(withSize: 14, weight: .regular)
        titleLabel.textColor = .foreground
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        discountField.keyboardType = .numberPad
        discountField.borderStyle = .roundedRect
        discountField.font = .appFont(withSize: 14, weight: .regular)
        discountField.textAlignment = .center
        discountField.constrainToSize(width: 56)
        
        let percentLabel = UILabel()
        percentLabel.text = "% off"
        percentLabel.font = .appFont(withSize: 14, weight: .regular)
        percentLabel.textColor = .foreground4
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)
        percentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        priceLabel.font = .appFont(withSize: 14, weight: .regular)
        priceLabel.textColor = .foreground5
        priceLabel.textAlignment = .right
        priceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let row = UIStackView(arrangedSubviews: [titleLabel, discountField, percentLabel, priceLabel])
        row.alignment = .center
        row.spacing = 12
        row.distribution = .fill
        
        container.addSubview(row)
        row.pinToSuperview()
    }
}

private final class SubscriptionStatsSection: UIView {
    private let titleLabel = UILabel()
    private let statsStack = UIStackView()
    private let button = UIButton(type: .system)
    
    private let active = SubscriptionStatView(title: "Active")
    private let expiring = SubscriptionStatView(title: "Expiring soon")
    private let lapsed = SubscriptionStatView(title: "Lapsed")
    
    init(title: String, buttonTitle: String) {
        super.init(frame: .zero)
        setup(title: title, buttonTitle: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(title: String, buttonTitle: String) {
        layer.cornerRadius = 16
        backgroundColor = .background2
        layer.borderWidth = 1
        layer.borderColor = UIColor.background4.cgColor
        
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.text = title
        
        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually
        statsStack.addArrangedSubview(active)
        statsStack.addArrangedSubview(expiring)
        statsStack.addArrangedSubview(lapsed)
        
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .appFont(withSize: 15, weight: .semibold)
        button.backgroundColor = .background
        button.layer.cornerRadius = 12
        button.setTitleColor(.foreground, for: .normal)
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, statsStack, button])
        stack.axis = .vertical
        stack.spacing = 16
        
        addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 16)
    }
    
    func update(active: Int, expiring: Int, lapsed: Int) {
        self.active.update(value: active.localized())
        self.expiring.update(value: expiring.localized())
        self.lapsed.update(value: lapsed.localized())
    }
}

private final class EarningsSection: UIView {
    private let titleLabel = UILabel()
    private let gridStack = UIStackView()
    
    private let subscriptions = SubscriptionStatView(title: "Subscriptions")
    private let ppv = SubscriptionStatView(title: "PPV")
    private let tips = SubscriptionStatView(title: "Tips/Zaps")
    private let dms = SubscriptionStatView(title: "Paid DMs")
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        layer.cornerRadius = 16
        backgroundColor = .background2
        layer.borderWidth = 1
        layer.borderColor = UIColor.background4.cgColor
        
        titleLabel.font = .appFont(withSize: 16, weight: .semibold)
        titleLabel.textColor = .foreground
        titleLabel.text = "Earnings (sats)"
        
        gridStack.axis = .vertical
        gridStack.spacing = 12
        
        let firstRow = UIStackView(arrangedSubviews: [subscriptions, ppv])
        firstRow.distribution = .fillEqually
        firstRow.spacing = 12
        
        let secondRow = UIStackView(arrangedSubviews: [tips, dms])
        secondRow.distribution = .fillEqually
        secondRow.spacing = 12
        
        gridStack.addArrangedSubview(firstRow)
        gridStack.addArrangedSubview(secondRow)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, gridStack])
        stack.axis = .vertical
        stack.spacing = 16
        
        addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 16)
    }
    
    func update(settings: SubscriptionSettings) {
        subscriptions.update(value: settings.earningsSubscriptions.localized())
        ppv.update(value: settings.earningsPPV.localized())
        tips.update(value: settings.earningsTips.localized())
        dms.update(value: settings.earningsDMs.localized())
    }
}

