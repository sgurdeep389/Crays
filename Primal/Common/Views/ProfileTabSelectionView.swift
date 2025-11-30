//
//  ProfileTabSelectionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.11.23..
//

import Combine
import UIKit

struct ProfileTabItem {
    let title: String
    let icon: UIImage?
}

final class ProfileTabSelectionView: UIView, Themeable {
    private(set) var buttons: [ProfileTabSelectionButton] = []
    private let selectionIndicator = ThemeableView().constrainToSize(height: 4).setTheme { $0.backgroundColor = .accent }
    private let items: [ProfileTabItem]
    
    @Published private(set) var selectedTab = 0
    private var cancellables: Set<AnyCancellable> = []
    
    init(items: [ProfileTabItem]) {
        self.items = items
        super.init(frame: .zero)
        configureButtons()
        setup()
    }
    
    convenience init(tabs: [String]) {
        let items = tabs.map { ProfileTabItem(title: $0, icon: nil) }
        self.init(items: items)
    }
    
    var isLoading = false {
        didSet {
            guard isLoading != oldValue else { return }
            buttons.forEach { $0.isUserInteractionEnabled = !isLoading }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = self?.isLoading == true ? 0.4 : 1
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ tab: Int, animated: Bool = true) {
        guard selectedTab != tab else { return }
        if !animated {
            setTab(tab, animated: false)
            layoutSubviews()
        }
        selectedTab = tab
    }
    
    func updateTheme() { }
}

private extension ProfileTabSelectionView {
    func configureButtons() {
        buttons = items.enumerated().map { index, item in
            let button = ProfileTabSelectionButton(item: item)
            button.addAction(.init(handler: { [weak self] _ in
                self?.selectedTab = index
            }), for: .touchUpInside)
            return button
        }
    }
    
    func setup() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 12
        addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .top], padding: 8).pinToSuperview(edges: .bottom, padding: 16)
        
        selectionIndicator.layer.cornerRadius = 2
        
        $selectedTab.dropFirst().removeDuplicates().sink { [weak self] newTab in
            self?.setTab(newTab, animated: true)
        }
        .store(in: &cancellables)
        
        setTab(0, animated: false)
    }
    
    func setTab(_ index: Int, animated: Bool = false) {
        guard let button = buttons[safe: index] else { return }
        buttons.enumerated().forEach { $0.element.updateSelection(isSelected: $0.offset == index) }
        selectionIndicator.removeFromSuperview()
        addSubview(selectionIndicator)
        selectionIndicator.pin(to: button, edges: .horizontal).pinToSuperview(edges: .bottom, padding: 4)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
}

final class ProfileTabSelectionButton: MyButton, Themeable {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let stack = UIStackView()
    private let item: ProfileTabItem
    
    init(item: ProfileTabItem) {
        self.item = item
        super.init(frame: .zero)
        setup()
        updateTheme()
        updateSelection(isSelected: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        iconView.image = (item.icon ?? UIImage(systemName: "circle"))?.withRenderingMode(.alwaysTemplate)
        iconView.contentMode = .scaleAspectFit
        iconView.constrainToSize(24)
        
        titleLabel.font = .appFont(withSize: 8, weight: .semibold)
        titleLabel.text = item.title
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        
        addSubview(stack)
        stack.pinToSuperview()
    }
    
    func updateSelection(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.titleLabel.alpha = isSelected ? 1 : 0
            self.iconView.tintColor = isSelected ? .accent : .foreground4
        }
    }
    
    func updateTheme() {
        backgroundColor = .clear
        titleLabel.textColor = .foreground
        iconView.tintColor = .foreground4
    }
}
