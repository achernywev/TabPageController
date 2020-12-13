//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by Aleksandr Chernyshev on 28.11.2020.
//

import UIKit

private let kTabPageViewCellIdentifier = "TabPageViewCellIdentifier"

fileprivate enum DefaultValues {
    static let horizontalOffset: CGFloat = 20
    static let collectionTopOffset: CGFloat = 30
    static let collectionBottomOffset: CGFloat = 10
    static let collectionViewHeight: CGFloat = 20
    static let itemSpace: CGFloat = 16
    
    static let collectionViewCellFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static let collectionViewCellFontColor = UIColor.gray
    static let selectedCollectionViewCellFontColor = UIColor.black
    
    static let indicatorViewHeight: CGFloat = 2
    static let separatorViewHeight: CGFloat = 1
    static let maxTitleWidth: CGFloat = 150
    static let animationDuration = 0.25
    static let indicatorViewInitialWidth: CGFloat = 150
    static let separatorViewColor = UIColor.darkGray
    static let indicatorViewColor = UIColor.black
}

open class TabPageItem {
    let viewController: UIViewController
    let viewControllerTitle: String
    fileprivate var width: CGFloat = DefaultValues.indicatorViewInitialWidth
    
    public init(viewController: UIViewController, viewControllerTitle: String) {
        self.viewController = viewController
        self.viewControllerTitle = viewControllerTitle
    }
}

open class TabPageController: UIViewController {
    //MARK: customization
    open var tabTitlesFont = DefaultValues.collectionViewCellFont {
        didSet {
            for item in pageItems {
                item.width = widthForText(item.viewControllerTitle)
            }
            reloadScreen()
        }
    }
    open var tabTitlesColor = DefaultValues.collectionViewCellFontColor {
        didSet {
            collectionView.reloadData()
        }
    }
    open var tabTitlesSelectedColor = DefaultValues.selectedCollectionViewCellFontColor {
        didSet {
            collectionView.reloadData()
        }
    }
    open var tabSeparatorColor: UIColor? {
        set {
            separatorView.backgroundColor = newValue
        }
        get {
            return separatorView.backgroundColor
        }
    }
    open var tabIndicatorColor: UIColor? {
        set {
            indicatorView.backgroundColor = newValue
        }
        get {
            return indicatorView.backgroundColor
        }
    }
    open var tabTitlesInset: CGFloat = DefaultValues.horizontalOffset {
        didSet {
            separatorLeadingConstraint.constant = tabTitlesInset
            separatorTrailingConstraint.constant = -tabTitlesInset
            reloadScreen()
        }
    }
    open var tabTitlesTopOffset: CGFloat = DefaultValues.collectionTopOffset {
        didSet {
            colletctionTopConstraint.constant = tabTitlesInset
            view.layoutIfNeeded()
        }
    }
    open var tabTitlesBottomOffset: CGFloat = DefaultValues.collectionBottomOffset {
        didSet {
            separatorTopConstraint.constant = tabTitlesInset
            view.layoutIfNeeded()
        }
    }
    open var tabTitlesHeight: CGFloat = DefaultValues.collectionViewHeight {
        didSet {
            colletctionHeightConstraint.constant = tabTitlesInset
            view.layoutIfNeeded()
            collectionView.reloadData()
        }
    }
    open var titlesInternalSpace: CGFloat = DefaultValues.itemSpace {
        didSet {
            reloadScreen()
        }
    }
    
    //MARK: private properties
    private weak var collectionView: UICollectionView!
    private weak var scrollView: UIScrollView!
    private weak var separatorView: UIView!
    private weak var indicatorView: UIView!

    private var colletctionTopConstraint: NSLayoutConstraint!
    private var colletctionHeightConstraint: NSLayoutConstraint!
    private var separatorTopConstraint: NSLayoutConstraint!
    private var separatorLeadingConstraint: NSLayoutConstraint!
    private var separatorTrailingConstraint: NSLayoutConstraint!
    private var indicatorWidthConstraint: NSLayoutConstraint!
    private var indicatorLeadingConstraint: NSLayoutConstraint!

    private var pageItems: [TabPageItem]
    private var selectedIndex: IndexPath! {
        didSet {
            if oldValue != self.selectedIndex {
                UIView.animate(withDuration: DefaultValues.animationDuration,
                               delay: 0,
                               options: [UIView.AnimationOptions.curveLinear, UIView.AnimationOptions.allowUserInteraction, UIView.AnimationOptions.beginFromCurrentState],
                               animations: {
                                self.scrollView.contentOffset = CGPoint(x: CGFloat(self.selectedIndex.row) * self.scrollView.bounds.size.width, y: 0)
                               },
                               completion: { _ in
                                var reloadItems: [IndexPath] = []
                                reloadItems.reserveCapacity(2)
                                if let old = oldValue {
                                    reloadItems.append(old)
                                }
                                if let index = self.selectedIndex {
                                    reloadItems.append(index)
                                }
                                self.collectionView.reloadItems(at: reloadItems)
                               }
                )
            }
        }
    }
    
    //MARK: initialization
    public init(pageItems: [TabPageItem]) {
        self.pageItems = pageItems;
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.white
        setupContent()
    }
    
    @available(*, unavailable, message: "use init(pageItems:) instead")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(pageItems:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    func createUI(rootView view: UIView) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let collView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collView.backgroundColor = UIColor.clear
        collView.isScrollEnabled = false;
        collView.showsHorizontalScrollIndicator = false;
        collView.translatesAutoresizingMaskIntoConstraints = false;
        collView.dataSource = self;
        collView.delegate = self;
        let bundle = Bundle(for: TabPageCollectionViewCell.classForCoder())
        let nib = UINib(nibName: String(describing: TabPageCollectionViewCell.self), bundle: bundle)
        collView.register(nib, forCellWithReuseIdentifier: kTabPageViewCellIdentifier)
        view.addSubview(collView)
        self.collectionView = collView
        
        let sepView = UIView()
        sepView.translatesAutoresizingMaskIntoConstraints = false
        sepView.backgroundColor = DefaultValues.separatorViewColor
        view.addSubview(sepView)
        self.separatorView = sepView
        
        let indView = UIView()
        indView.translatesAutoresizingMaskIntoConstraints = false
        indView.backgroundColor = DefaultValues.indicatorViewColor
        separatorView.addSubview(indView)
        self.indicatorView = indView
        
        let scrView = UIScrollView()
        scrView.isPagingEnabled = true
        scrView.bounces = false
        scrView.delegate = self;
        scrView.showsHorizontalScrollIndicator = false
        scrView.showsVerticalScrollIndicator = false
        scrView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrView)
        self.scrollView = scrView
        
        colletctionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant:tabTitlesHeight)
        colletctionHeightConstraint.isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        colletctionTopConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant:tabTitlesTopOffset)
        colletctionTopConstraint.isActive = true
        
        separatorView.heightAnchor.constraint(equalToConstant:DefaultValues.separatorViewHeight).isActive = true
        separatorLeadingConstraint = separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:tabTitlesInset)
        separatorLeadingConstraint.isActive = true
        separatorTrailingConstraint = separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-tabTitlesInset)
        separatorTrailingConstraint.isActive = true
        separatorTopConstraint = separatorView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant:tabTitlesBottomOffset)
        separatorTopConstraint.isActive = true
        
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: DefaultValues.indicatorViewInitialWidth)
        indicatorWidthConstraint.isActive = true
        indicatorLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor)
        indicatorLeadingConstraint.isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant:DefaultValues.indicatorViewHeight).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupContent() {
        let count = self.pageItems.count
        switch count {
            case 0:
                return
            case 1:
                let item = pageItems.first!
                
                let controller = item.viewController
                addControllerAsChild(controller)
                
                controller.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                controller.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
                
                item.width = widthForText(item.viewControllerTitle)
            default:
                var prevItem = pageItems.first!
                addControllerAsChild(prevItem.viewController)
                
                prevItem.viewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                prevItem.width = widthForText(prevItem.viewControllerTitle)
                
                for index in 1..<count {
                    let item = pageItems[index]
                    addControllerAsChild(item.viewController)
                    
                    item.viewController.view.leadingAnchor.constraint(equalTo: prevItem.viewController.view.trailingAnchor).isActive = true
                    prevItem = item
                    
                    item.width = widthForText(item.viewControllerTitle)
                }
                prevItem.viewController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        }
        selectedIndex = IndexPath(row: 0, section: 0)
    }
    
    //MARK: UIViewControler methods
    open override func loadView() {
        let view = UIView()
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        createUI(rootView: view)
        self.view = view
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadScreen()
    }
    
    //MARK: private methods
    private func reloadScreen() {
        view.layoutIfNeeded()
        collectionView.reloadData()
        checkAndResizeIfNeeded()
        scrollViewDidScroll(scrollView)
    }
    
    private func widthForText(_ text: String) -> CGFloat {
        let textS = NSString(string: text)
        return CGFloat.minimum(DefaultValues.maxTitleWidth, ceil(textS.size(withAttributes: [NSAttributedString.Key.font : tabTitlesFont]).width))
    }
    
    private func widthAtIndex(_ index: Int) -> CGFloat {
        let width = index < pageItems.count ? pageItems[index].width : DefaultValues.indicatorViewInitialWidth
        return titlesInternalSpace + width
    }
    
    private func checkAndResizeIfNeeded() {
        let count = pageItems.count
        
        let fullWidth = (0..<count).reduce(0) { result, index -> CGFloat in
            return result + widthAtIndex(index)
        } + 2 * tabTitlesInset
        
        if(fullWidth < collectionView.bounds.size.width) {
            for index in 0..<count {
                pageItems[index].width = (collectionView.bounds.size.width - 2 * tabTitlesInset) / CGFloat(count) - titlesInternalSpace
            }
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
        
        controller.didMove(toParent:self)
    }
}

//MARK: <UIScrollViewDelegate> methods
extension TabPageController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        
        let maxScrollOffset = scrollView.contentSize.width - scrollView.bounds.size.width;
        let maxHeaderOffset = collectionView.contentSize.width - collectionView.bounds.size.width;
        
        let percent = scrollView.contentOffset.x / maxScrollOffset;
        let headerOffset = maxHeaderOffset * percent;
        
        let offset = scrollView.contentOffset.x;
        let numOfPages = Int(floor(offset / scrollView.bounds.size.width))
        let pagePercent = fmod(offset, scrollView.bounds.size.width) / scrollView.bounds.size.width;
        
        let fullPrevIndicatorLength = (0..<numOfPages).reduce(0, { result, index -> CGFloat in
            return result + widthAtIndex(index)
        })
        let currentIndicatorWidth = widthAtIndex(numOfPages)
        
        let indicatorOffset = fullPrevIndicatorLength + pagePercent * currentIndicatorWidth - headerOffset;
        indicatorLeadingConstraint.constant = indicatorOffset //CGFloat.maximum(0, CGFloat.minimum(separatorView.bounds.size.width - indicatorView.bounds.size.width, indicatorOffset));
        indicatorWidthConstraint.constant = currentIndicatorWidth + (widthAtIndex(numOfPages + 1) - currentIndicatorWidth) * pagePercent
        
        UIView.animate(withDuration: DefaultValues.animationDuration,
                       delay: 0,
                       options: [UIView.AnimationOptions.curveLinear, UIView.AnimationOptions.allowUserInteraction, UIView.AnimationOptions.beginFromCurrentState],
                       animations: {
                        self.collectionView.contentOffset = CGPoint(x: headerOffset, y: 0)
                        self.view.layoutIfNeeded()
                       },
                       completion: nil
        )
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.scrollView == scrollView else { return }
        let numOfPage = Int(floor(scrollView.contentOffset.x / scrollView.bounds.size.width))
        selectedIndex = IndexPath(row: numOfPage, section: 0)
    }
}

//MARK: <UICollectionViewDataSource> methods
extension TabPageController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTabPageViewCellIdentifier, for: indexPath) as! TabPageCollectionViewCell
        cell.titleLabel.font = tabTitlesFont
        cell.titleLabel.textColor = (selectedIndex == indexPath) ? tabTitlesSelectedColor : tabTitlesColor
        cell.titleLabel.textAlignment = NSTextAlignment.center
        
        cell.titleLabel.text = pageItems[indexPath.row].viewControllerTitle
        return cell
    }
}

//MARK: <UICollectionViewDelegate> methods
extension TabPageController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
    }
}

//MARK: <UICollectionViewDelegateFlowLayout> methods
extension TabPageController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = widthAtIndex(indexPath.row)
        return CGSize(width: width, height: tabTitlesHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: tabTitlesInset, bottom: 0, right: tabTitlesInset)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1;
    }
}
