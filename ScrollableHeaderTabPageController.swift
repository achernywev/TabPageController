import Foundation

open class ScrollableHeaderTabPageController<Cell: TabPageCell>: TabPageController<Cell> {
    // MARK: - public properties
    public var headerView: UIView? {
        didSet {
            if let oldValue = oldValue {
                mainStackView.removeArrangedSubview(oldValue)
                oldValue.removeFromSuperview()
            }
            if let newValue = headerView {
                mainStackView.insertArrangedSubview(newValue, at: 0)
            }
        }
    }
    
    // MARK: - private properties
    private lazy var mainScrollView: UIScrollView = {
        let mainScrollView = UIScrollView()
        mainScrollView.isScrollEnabled = false
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.addSubview(mainStackView)
        return mainScrollView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let mainStackView = UIStackView(arrangedSubviews: [contentView])
        mainStackView.axis = .vertical
        return mainStackView
    }()
    
    // MARK: UIViewControler methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        contentView.removeFromSuperview()
        view.addSubview(mainScrollView)
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        recognizer.cancelsTouchesInView = true
        view.addGestureRecognizer(recognizer)
        setupConstraints()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        stopOffsetAnimation()
    }
    
    // MARK: - overriden methods
    public override func updatePageItems(_ pageItems: [Item]) {
        let pageItems = pageItems.map {
            let scrollView = $0.viewController.view.subviews.first as? UIScrollView
            scrollView?.isScrollEnabled = false
            return $0
        }
        super.updatePageItems(pageItems)
    }
    
    override func selectedIndexUpdated(from oldValue: Int?, to newValue: Int?) {
        super.selectedIndexUpdated(from: oldValue, to: newValue)
        guard oldValue != newValue else { return }
        stopOffsetAnimation()
    }
    
    // MARK: - private methods
    private func setupConstraints() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
        ])
        
        let offset = view.safeAreaInsets.top + view.safeAreaInsets.bottom
        contentView.removeConstraints(contentView.constraints)
        contentView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor, constant: offset).isActive = true
    }
    
    // MARK: - pan gesture handler
    private var lastPan: Date?
    private var contentOffsetAnimation: TimerAnimation?
    private var state: State = .default
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let newPan = Date()
        switch recognizer.state {
        case .began:
            stopOffsetAnimation()
            state = .dragging(initialOffset: contentOffset)
        
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            if case .dragging(let initialOffset) = state {
                contentOffset = clampOffset(initialOffset - translation)
            }
        
        case .ended:
            state = .default
            
            // Pan gesture recognizers report a non-zero terminal velocity even
            // when the user had stopped dragging:
            // https://stackoverflow.com/questions/19092375/how-to-determine-true-end-velocity-of-pan-gesture
            // In virtually all cases, the pan recognizer seems to call this
            // handler at intervals of less than 100ms while the user is
            // dragging, so if this call occurs outside that window, we can
            // assume that the user had stopped, and finish scrolling without
            // deceleration.
            let userHadStoppedDragging = newPan.timeIntervalSince(lastPan ?? newPan) >= 0.1
            let velocity: CGFloat = userHadStoppedDragging ? 0.0 : recognizer.velocity(in: recognizer.view).y
            completeGesture(withVelocity: -velocity)
            
        case .cancelled, .failed:
            state = .default
            
        case .possible:
            break
        
        @unknown default:
            fatalError()
        }
        lastPan = newPan
    }
}

// MARK: - working with main scroll view
private extension ScrollableHeaderTabPageController {
    enum State {
        case `default`
        case dragging(initialOffset: CGPoint)
    }
    
    var headerHeight: CGFloat { headerView?.bounds.size.height ?? 0.0 }
    var contentScrollView: UIScrollView? {
        guard let selectedIndex = selectedIndex else { return nil }
        let viewController = pageItems[selectedIndex].viewController
        return viewController.view.subviews.first as? UIScrollView
    }
    
    var contentOffset: CGPoint {
        get {
            var contentScrollOffset = contentScrollView?.contentOffset ?? .zero
            if contentScrollOffset.y > 0 {
                contentScrollOffset.y += headerHeight
                return contentScrollOffset
            } else {
                return mainScrollView.contentOffset
            }
        }
        set {
            if newValue.y > headerHeight {
                mainScrollView.contentOffset = CGPoint(x: 0, y: headerHeight)
                contentScrollView?.contentOffset = CGPoint(x: 0, y: newValue.y - headerHeight)
                
            } else {
                contentScrollView?.contentOffset = .zero
                mainScrollView.contentOffset = CGPoint(x: 0, y: newValue.y)
            }
        }
    }
    
    var contentOffsetBounds: CGRect {
        var contentSize = mainScrollView.contentSize
        let contentHeight = contentView.bounds.size.height - scrollView.bounds.size.height
        + (contentScrollView?.contentSize.height ?? scrollView.bounds.size.height)
        
        contentSize.height = headerHeight + contentHeight
        let width = mainScrollView.bounds.width
        let height = contentSize.height - mainScrollView.bounds.height
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func startDeceleration(withVelocity velocity: CGFloat) {
        let d = UIScrollView.DecelerationRate.normal.rawValue
        let parameters = DecelerationTimingParameters(initialValue: contentOffset,
                                                      initialVelocity: CGPoint(x: 0.0, y: velocity),
                                                      decelerationRate: d, threshold: 0.5)

        let destination = parameters.destination
        let intersection = getIntersection(rect: contentOffsetBounds, segment: (contentOffset, destination))

        let duration: TimeInterval
        if let intersection = intersection, let intersectionDuration = parameters.duration(to: intersection) {
            duration = intersectionDuration
        } else {
            duration = parameters.duration
        }

        contentOffsetAnimation = TimerAnimation(
            duration: duration,
            animations: { [weak self] _, time in
                self?.contentOffset = parameters.value(at: time)
            },
            completion: { [weak self] finished in
                guard finished && intersection != nil else { return }
                let velocity = parameters.velocity(at: duration).y
                self?.bounce(withVelocity: velocity)
            })
    }

    func bounce(withVelocity velocity: CGFloat) {
        let restOffset = contentOffset.clamped(to: contentOffsetBounds)
        let displacement = contentOffset - restOffset
        let threshold = 0.5 / UIScreen.main.scale
        let spring = Spring(mass: 1, stiffness: 100, dampingRatio: 1)

        let parameters = SpringTimingParameters(spring: spring,
                                                displacement: displacement,
                                                initialVelocity: CGPoint(x: 0.0, y: velocity),
                                                threshold: threshold)

        contentOffsetAnimation = TimerAnimation(
            duration: parameters.duration,
            animations: { [weak self] _, time in
                self?.contentOffset = restOffset + parameters.value(at: time)
            })
    }

    func clampOffset(_ offset: CGPoint) -> CGPoint {
        let rubberBand = RubberBand(dims: mainScrollView.bounds.size, bounds: contentOffsetBounds)
        return rubberBand.clamp(offset)
    }
    
    func completeGesture(withVelocity velocity: CGFloat) {
        if contentOffsetBounds.containsIncludingBorders(contentOffset) {
            startDeceleration(withVelocity: velocity)
        } else {
            bounce(withVelocity: velocity)
        }
    }
    
    func stopOffsetAnimation() {
        contentOffsetAnimation?.invalidate()
        contentOffsetAnimation = nil
    }
}
