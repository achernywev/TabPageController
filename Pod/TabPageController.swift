import UIKit

private let TabPageCellIdentifier = "TabPageViewCellIdentifier"
private let defaultIndicatorWidth = 150.0

open class TabPageController<Cell: TabPageCell>: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource,
                                                 UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public typealias Item = TabPageItem<Cell.Model>
    
    // MARK: - customization properties
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    public var tabTitlesInset: CGFloat = 16.0 {
        didSet {
            separatorLeadingConstraint.constant = tabTitlesInset
            separatorTrailingConstraint.constant = -tabTitlesInset
            reloadScreen()
        }
    }
    
    public var tabTitlesInternalSpace: CGFloat = 8.0 {
        didSet {
            reloadScreen()
        }
    }
    
    public var tabTitlesHeight: CGFloat = 40.0 {
        didSet {
            collectionHeightConstraint.constant = tabTitlesHeight
            view.layoutIfNeeded()
            collectionView.reloadData()
        }
    }
    
    public var tabTitlesBottomOffset: CGFloat = 0.0 {
        didSet {
            contentView.setCustomSpacing(tabTitlesBottomOffset, after: collectionView)
            view.layoutIfNeeded()
        }
    }
    
    public var tabSeparatorHeight: CGFloat = 1.0 {
        didSet {
            separatorHeightConstraint.constant = tabSeparatorHeight
            view.layoutIfNeeded()
        }
    }
    
    public var tabSeparatorBottomOffset: CGFloat = 8.0 {
        didSet {
            contentView.setCustomSpacing(tabSeparatorBottomOffset, after: separatorContainerView)
            view.layoutIfNeeded()
        }
    }
    
    public var indicatorViewHeight: CGFloat = 4.0 {
        didSet {
            indicatorHeightConstraint.constant = indicatorViewHeight
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - public readonly properties
    public private(set) lazy var separatorView: UIView = {
        let sepView = UIView()
        sepView.addSubview(indicatorView)
        sepView.backgroundColor = .black
        sepView.clipsToBounds = false
        return sepView
    }()
    
    public private(set) lazy var indicatorView: UIView = {
        let indView = UIView()
        indView.backgroundColor = .blue
        indView.layer.cornerRadius = indicatorViewHeight
        indView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        indView.clipsToBounds = true
        return indView
    }()
    
    // MARK: - private properties
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [collectionView, separatorContainerView, scrollView])
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collView.backgroundColor = UIColor.clear
        collView.isScrollEnabled = false
        collView.showsHorizontalScrollIndicator = false
        collView.dataSource = self
        collView.delegate = self
        collView.register(Cell.self, forCellWithReuseIdentifier: TabPageCellIdentifier)
        return collView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrView = UIScrollView()
        scrView.isPagingEnabled = true
        scrView.bounces = false
        scrView.delegate = self
        scrView.showsHorizontalScrollIndicator = false
        scrView.showsVerticalScrollIndicator = false
        return scrView
    }()
    
    private lazy var separatorContainerView: UIView = {
        let separatorContainerView = UIView()
        separatorContainerView.clipsToBounds = false
        separatorContainerView.addSubview(separatorView)
        return separatorContainerView
    }()
    
    private var indicatorWidthConstraint: NSLayoutConstraint!
    private var indicatorLeadingConstraint: NSLayoutConstraint!
    private var separatorLeadingConstraint: NSLayoutConstraint!
    private var separatorTrailingConstraint: NSLayoutConstraint!
    private var separatorHeightConstraint: NSLayoutConstraint!
    private var indicatorHeightConstraint: NSLayoutConstraint!
    private var collectionHeightConstraint: NSLayoutConstraint!
    
    private var selectedIndex: Int? {
        didSet {
            if oldValue != self.selectedIndex {
                startUpdatingAppearingForController(atIndex: selectedIndex,
                                                    replacingControllerAtIndex: oldValue)
                UIView.animate(withDuration: 0.25,
                               delay: 0,
                               options: [.curveLinear, .allowUserInteraction, .beginFromCurrentState],
                               animations: {
                    self.scrollView.contentOffset = CGPoint(
                        x: CGFloat(self.selectedIndex ?? 0) * self.scrollView.bounds.size.width,
                        y: 0
                    )
                },
                               completion: { _ in
                    let indexPaths = [oldValue?.indexPath, self.selectedIndex?.indexPath].compactMap { $0 }
                    self.collectionView.reloadItems(at: indexPaths)
                    self.endUpdatingAppearingForController(atIndex: self.selectedIndex,
                                                           replacingControllerAtIndex: oldValue)
                })
            }
        }
    }
    
    private var pageItems: [Item] = [] {
        didSet {
            oldValue.forEach {
                $0.viewController.willMove(toParent: nil)
                $0.viewController.removeFromParent()
            }
            updateScreen()
        }
    }
    
    private var isHeaderViewHidden: Bool = false {
        didSet {
            collectionView.isHidden = isHeaderViewHidden
            separatorContainerView.isHidden = isHeaderViewHidden
        }
    }
    
    // MARK: UIViewControler methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        setupConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginAppearence(true, forControllerAtIndex: selectedIndex, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        endAppearence(forControllerAtIndex: selectedIndex)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        beginAppearence(false, forControllerAtIndex: selectedIndex, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endAppearence(forControllerAtIndex: selectedIndex)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadScreen()
    }
    
    // MARK: public methods
    public func updatePageItems(_ pageItems: [Item]) {
        self.pageItems = pageItems
    }
    
    // MARK: private methods
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.setCustomSpacing(tabTitlesBottomOffset, after: collectionView)
        contentView.setCustomSpacing(tabSeparatorBottomOffset, after: separatorContainerView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: tabTitlesHeight)
        collectionHeightConstraint.isActive = true
        
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.topAnchor.constraint(equalTo: separatorContainerView.topAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: separatorContainerView.bottomAnchor).isActive = true
        separatorHeightConstraint = separatorView.heightAnchor.constraint(equalToConstant: tabSeparatorHeight)
        separatorHeightConstraint.isActive = true
        separatorLeadingConstraint = separatorView.leadingAnchor.constraint(equalTo: separatorContainerView.leadingAnchor,
                                                                            constant: tabTitlesInset)
        separatorLeadingConstraint.isActive = true
        separatorTrailingConstraint = separatorView.trailingAnchor.constraint(equalTo: separatorContainerView.trailingAnchor,
                                                                              constant: -tabTitlesInset)
        separatorTrailingConstraint.isActive = true
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: defaultIndicatorWidth)
        indicatorWidthConstraint.isActive = true
        indicatorLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor)
        indicatorLeadingConstraint.isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        indicatorHeightConstraint = indicatorView.heightAnchor.constraint(equalToConstant: indicatorViewHeight)
        indicatorHeightConstraint.isActive = true
    }
    
    private func updateScreen() {
        view.setNeedsDisplay()
        
        let count = self.pageItems.count
        self.isHeaderViewHidden = count < 2
        
        switch count {
        case 0:
            selectedIndex = nil
            return
        case 1:
            let controller = pageItems.first!.viewController
            addControllerAsChild(controller)
            controller.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            controller.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        default:
            var prevItem = pageItems.first!
            addControllerAsChild(prevItem.viewController)
            prevItem.viewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            
            for index in 1..<count {
                let item = pageItems[index]
                addControllerAsChild(item.viewController)
                item.viewController.view.leadingAnchor.constraint(equalTo: prevItem.viewController.view.trailingAnchor).isActive = true
                prevItem = item
            }
            prevItem.viewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        }
        selectedIndex = 0
        reloadScreen()
    }
    
    private func reloadScreen() {
        view.layoutIfNeeded()
        collectionView.reloadData()
        checkAndResizeIfNeeded()
        scrollViewDidScroll(scrollView)
    }
    
    private func checkAndResizeIfNeeded() {
        // potential place where calculate the width only once and store it somewhere
    }
    
    private func widthAtIndex(_ index: Int) -> CGFloat {
        let calculateWidth = { (intIndex: Int) -> CGFloat in
            guard let cell = self.collectionView(self.collectionView, cellForItemAt: intIndex.indexPath) as? Cell else {
                return 0.0
            }
            return cell.width(forModel: self.pageItems[intIndex].model)
        }
        
        let count = pageItems.count
        let fullWidth = (0 ..< count).reduce(0) { result, index -> CGFloat in
            return result + calculateWidth(index)
        } + 2 * tabTitlesInset
        
        if fullWidth < collectionView.bounds.size.width {
            return (collectionView.bounds.size.width - 2 * tabTitlesInset) / CGFloat(count)
        } else {
            let width = (0 ..< count).contains(index) ? calculateWidth(index) : defaultIndicatorWidth
            return 2.0 * tabTitlesInternalSpace + width
        }
    }
    
    private func addControllerAsChild(_ controller: UIViewController) {
        self.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(controller.view)
        
        controller.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        controller.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        controller.didMove(toParent: self)
    }
    
    private func controller(atIndex index: Int?) -> UIViewController? {
        guard let index = index, index >= 0, index < pageItems.count else { return nil }
        return pageItems[index].viewController
    }
    
    private func beginAppearence(_ isAppearing: Bool, forControllerAtIndex index: Int?, animated: Bool) {
        controller(atIndex: index)?.beginAppearanceTransition(isAppearing, animated: animated)
    }
    
    private func endAppearence(forControllerAtIndex index: Int?) {
        controller(atIndex: index)?.endAppearanceTransition()
    }
    
    private func startUpdatingAppearingForController(atIndex appearingIndex: Int?,
                                                     replacingControllerAtIndex disappearingIndex: Int?) {
        guard let disappearingIndex = disappearingIndex else { return }
        beginAppearence(true, forControllerAtIndex: appearingIndex, animated: true)
        beginAppearence(false, forControllerAtIndex: disappearingIndex, animated: true)
    }
    
    private func endUpdatingAppearingForController(atIndex appearingIndex: Int?,
                                                   replacingControllerAtIndex disappearingIndex: Int?) {
        guard let disappearingIndex = disappearingIndex else { return }
        endAppearence(forControllerAtIndex: appearingIndex)
        endAppearence(forControllerAtIndex: disappearingIndex)
    }
    
    // MARK: <UIScrollViewDelegate> methods
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        
        let maxScrollOffset = scrollView.contentSize.width - scrollView.bounds.size.width
        let maxHeaderOffset = collectionView.contentSize.width - collectionView.bounds.size.width
        
        let percent = scrollView.contentOffset.x / maxScrollOffset
        let headerOffset = maxHeaderOffset * percent
        
        let offset = scrollView.contentOffset.x
        let numOfPages = Int(floor(offset / scrollView.bounds.size.width))
        let pagePercent = fmod(offset, scrollView.bounds.size.width) / scrollView.bounds.size.width
        
        let fullPrevIndicatorLength = (0..<numOfPages).reduce(0, { result, index -> CGFloat in
            return result + widthAtIndex(index)
        })
        let currentIndicatorWidth = widthAtIndex(numOfPages)
        
        let indicatorOffset = fullPrevIndicatorLength + pagePercent * currentIndicatorWidth - headerOffset
        let newWidth = currentIndicatorWidth + (widthAtIndex(numOfPages + 1) - currentIndicatorWidth) * pagePercent
        indicatorLeadingConstraint.constant = CGFloat.maximum(0, indicatorOffset)
        indicatorWidthConstraint.constant = newWidth
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveLinear, .allowUserInteraction, .beginFromCurrentState],
                       animations: {
            self.collectionView.contentOffset = CGPoint(x: headerOffset, y: 0)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        let numOfPage = Int(floor(scrollView.contentOffset.x / scrollView.bounds.size.width))
        selectedIndex = numOfPage
    }
    
    // MARK: <UICollectionViewDataSource> methods
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabPageCellIdentifier,
                                                      for: indexPath) as! Cell
        let model = pageItems[indexPath.row].model
        cell.update(for: model, isSelected: selectedIndex == indexPath.index)
        return cell
    }
    
    // MARK: <UICollectionViewDelegate> methods
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.index
    }
    
    // MARK: <UICollectionViewDelegateFlowLayout> methods
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = widthAtIndex(indexPath.index)
        return CGSize(width: width, height: tabTitlesHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: tabTitlesInset, bottom: 0, right: tabTitlesInset)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
}

private extension IndexPath {
    var index: Int { item }
}

private extension Int {
    var indexPath: IndexPath { IndexPath(item: self, section: 0) }
}
