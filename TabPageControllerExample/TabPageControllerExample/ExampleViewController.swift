import UIKit
import TabPageController

final class ExampleViewController: UICollectionViewController {
    private let numberOfItems = 30
    private let reuseIdentifier = "ExampleViewController.ReuseIdentifier"
    
    init() {
        let layout = UICollectionViewLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(TabPageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - <UICollectionViewDataSource> methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)
        guard let modelCell = cell as? TabPageCell else { return cell }
        modelCell.update(for: "Cell #\(indexPath.row)", isSelected: true)
        return modelCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("SELECT: \(indexPath)")
    }
}

private extension ExampleViewController {
    private var layout: UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12.0
            return section
        })
        return layout
    }
}
