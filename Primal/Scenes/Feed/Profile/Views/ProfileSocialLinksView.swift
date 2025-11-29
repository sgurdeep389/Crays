import UIKit

struct ProfileSocialLinkItem {
    let type: SocialLinkType
    let url: URL
}

final class ProfileSocialLinksView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    private var items: [ProfileSocialLinkItem] = []
    
    var didSelect: ((URL) -> Void)?
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileSocialLinkCell.self, forCellWithReuseIdentifier: "socialLink")
        
        addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        isHidden = true
    }
    
    func update(with items: [ProfileSocialLinkItem]) {
        self.items = items
        isHidden = items.isEmpty
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialLink", for: indexPath)
        if let cell = cell as? ProfileSocialLinkCell {
            cell.configure(with: items[indexPath.item].type)
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = items[safe: indexPath.item]?.url else { return }
        didSelect?(url)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: 48, height: 48)
    }
}

final class ProfileSocialLinkCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = .background2
        contentView.layer.cornerRadius = 24
        contentView.layer.borderColor = UIColor.background4.cgColor
        contentView.layer.borderWidth = 1
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.centerToSuperview()
        imageView.constrainToSize(28)
    }
    
    func configure(with type: SocialLinkType) {
        let image = UIImage(named: type.iconName)
        if let image {
            imageView.image = image
            if image.renderingMode == .alwaysTemplate {
                imageView.tintColor = .foreground
            }
        } else {
            imageView.image = nil
        }
    }
}

