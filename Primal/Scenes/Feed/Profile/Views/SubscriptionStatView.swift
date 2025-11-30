import UIKit

final class SubscriptionStatView: UIView {
    private let iconView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        setup(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        layer.borderWidth = 1
        layer.borderColor = UIColor.background4.cgColor
        backgroundColor = .background
        
        iconView.image = UIImage(systemName: "bolt.fill")
        iconView.tintColor = .accent
        iconView.contentMode = .scaleAspectFit
        iconView.constrainToSize(16)
        
        valueLabel.font = .appFont(withSize: 20, weight: .semibold)
        valueLabel.textColor = .foreground
        valueLabel.textAlignment = .center
        
        titleLabel.font = .appFont(withSize: 10, weight: .regular)
        titleLabel.text = title
        titleLabel.textColor = .foreground4
        titleLabel.textAlignment = .center
        
        let topStack = UIStackView(arrangedSubviews: [iconView, valueLabel])
        topStack.axis = .horizontal
        topStack.spacing = 6
        topStack.alignment = .center
        topStack.distribution = .equalCentering
        
        let stack = UIStackView(arrangedSubviews: [topStack, titleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        
        addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 16)
    }
    
    func configure(value: String, subtitle: String) {
        valueLabel.text = value
        titleLabel.text = subtitle
    }
    
    func update(value: String) {
        valueLabel.text = value
    }
}

