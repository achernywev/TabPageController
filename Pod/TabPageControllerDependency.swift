import UIKit

public protocol TabPageModelProtocol {
    var title: String { get }
}

public protocol TabPageCellProtocol: UICollectionViewCell {
    associatedtype Model: TabPageModelProtocol
    func update(for model: Model, isSelected: Bool)
}

public extension TabPageCellProtocol {
    func width(forModel model: Model) -> CGFloat {
        update(for: model, isSelected: false)
        let fitingSize = CGSize(width: CGFloat.infinity, height: contentView.bounds.size.height)
        return ceil(contentView.systemLayoutSizeFitting(fitingSize).width)
    }
}

final public class TabPageItem<Model: TabPageModelProtocol> {
    let viewController: UIViewController
    var model: Model
    
    init(viewController: UIViewController, model: Model) {
        self.viewController = viewController
        self.model = model
    }
}
