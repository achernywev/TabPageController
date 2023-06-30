import UIKit

final public class TabPageCell: UICollectionViewCell, TabPageCellProtocol {
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 14.0)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(for model: String, isSelected: Bool) {
        titleLabel.text = model
        titleLabel.alpha = isSelected == true ? 1.0 : 0.6
    }
    
    private func setup() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

extension TabPageItem where Model == String {
    public convenience init(viewController: UIViewController, title: String) {
        self.init(viewController: viewController, model: title)
    }
}
extension String: TabPageModelProtocol {
    public var title: String { self }
}
