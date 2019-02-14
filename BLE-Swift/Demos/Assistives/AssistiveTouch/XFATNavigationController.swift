//
//  XFATNavigationController.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
@objc protocol XFATNavigationControllerDelegate: NSObjectProtocol {
    func navigationController(_ navigationController: XFATNavigationController?, actionBeginAt point: CGPoint)
    func navigationController(_ navigationController: XFATNavigationController?, actionEndAt point: CGPoint)
}

class XFATNavigationController: UIViewController {
    
    private(set) var viewControllers: [XFATViewController] = []
    private(set) var show = false
    weak var delegate: XFATNavigationControllerDelegate?
    private var pushPosition: [XFATPosition] = []
    private var contentItem: XFATItemView?
    private var contentView: UIView?
    private var effectView: UIVisualEffectView?
    
    private var _contentPoint = CGPoint.zero
    private var contentPoint: CGPoint {
        get {
            return _contentPoint
        }
        set(contentPoint) {
            if !show {
                _contentPoint = contentPoint
                contentView?.center = _contentPoint
                contentItem?.center = _contentPoint
            }
        }
    }
    
    private var _contentAlpha: CGFloat = 0.0
    private var contentAlpha: CGFloat {
        get {
            return _contentAlpha
        }
        set(contentAlpha) {
            if !show {
                _contentAlpha = contentAlpha
                contentView?.alpha = _contentAlpha
                contentItem?.alpha = _contentAlpha
            }
        }
    }
    private var timer: Timer?
    
    required init(rootViewController viewController: XFATViewController?) {
        super.init(nibName: nil, bundle: nil)
        
        var vc:XFATViewController? = viewController
        
        if vc == nil {
            vc = XFATViewController()
        }
        let rootViewController: XFATViewController? = vc
        rootViewController?.navigationController = self
        viewControllers = [rootViewController] as! [XFATViewController]
        if let array = [AnyHashable]() as? [XFATPosition] {
            pushPosition = array
        }
        
    }
    
    @objc func spread() {
        if show {
            return
        }
        stopTimer()
        invokeActionBeginDelegate()
        self.show = true
        let count = viewControllers.first?.items.count
        for i in 0..<(count ?? 0) {
            let item: XFATItemView? = viewControllers.first?.items[i]
            item?.alpha = 0
            item?.center = contentPoint
            if let item = item {
                view.addSubview(item)
            }
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                item?.center = XFATPosition(count: count!, index: i).center
                item?.alpha = 1
            })
        }
        
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            self.contentView?.frame = XFATLayoutAttributes.contentViewSpreadFrame()
            self.effectView?.frame = self.contentView?.bounds ?? CGRect.zero
            self.contentView?.alpha = 1
            self.contentItem?.center = XFATPosition(count: count!, index: (count ?? 0) - 1).center
            self.contentItem?.alpha = 0
        })
    }
    
    @objc func shrink() {
        if !show {
            return
        }
        beginTimer()
        self.show = false
        for item: XFATItemView in (viewControllers.last?.items)! {
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                item.center = self.contentPoint
                item.alpha = 0
            })
        }
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            self.viewControllers.last?.backItem!.center = self.contentPoint
            self.viewControllers.last?.backItem!.alpha = 0
        })
        
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            self.contentView?.frame = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
            self.contentView?.center = self.contentPoint
            self.effectView?.frame = self.contentView?.bounds ?? CGRect.zero
            self.contentItem?.alpha = 1
            self.contentItem?.center = self.contentPoint
        }) { finished in
            for viewController: XFATViewController in self.viewControllers {
                
                for view: XFATItemView in viewController.items {
                    view.removeFromSuperview();
                }
                
                //                viewController.items.makeObjectsPerform(#selector(XFATNavigationController.removeFromSuperview))
                viewController.backItem!.removeFromSuperview()
            }
            self.viewControllers = [self.viewControllers.first] as! [XFATViewController]
            self.invokeActionEndDelegate()
        }
    }
    
    func push(_ viewController: XFATViewController?, atPisition position: XFATPosition?) {
        let oldViewController: XFATViewController? = viewControllers.last
        for item: XFATItemView? in (oldViewController?.items)! {
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                item?.alpha = 0
            })
        }
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            oldViewController?.backItem!.alpha = 0
        })
        
        let count = viewController?.items.count
        for i in 0..<(count ?? 0) {
            let item: XFATItemView? = viewController?.items[i]
            item?.alpha = 0
            item?.center = (position?.center)!
            if let item = item {
                view.addSubview(item)
            }
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                item?.center = XFATPosition(count: count!, index: i).center
                item?.alpha = 1
            })
        }
        viewController?.backItem!.alpha = 0
        viewController?.backItem!.center = (position?.center)!
        if let backItem = viewController?.backItem {
            view.addSubview(backItem)
        }
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            viewController?.backItem!.center = self.view.center
            viewController?.backItem!.alpha = 1
        })
        
        viewController?.navigationController = self
        if let viewController = viewController {
            viewControllers.append(viewController)
        }
        if let position = position {
            pushPosition.append(position)
        }
    }
    
    func popViewController() {
        if pushPosition.count > 0 {
            let position: XFATPosition? = pushPosition.last
            for item: XFATItemView? in (viewControllers.last?.items)! {
                UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                    item?.center = (position?.center)!
                    item?.alpha = 0
                })
            }
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                self.viewControllers.last?.backItem!.center = (position?.center)!
                self.viewControllers.last?.backItem!.alpha = 0
            }) { finished in
                //                viewControllers.last?.items.makeObjectsPerform(#selector(XFATNavigationController.removeFromSuperview))
                self.viewControllers.last?.items.forEach { item in
                    item.removeFromSuperview()
                }
                
                
                self.viewControllers.last?.backItem!.removeFromSuperview()
                self.viewControllers.removeLast()
                for item: XFATItemView? in (self.viewControllers.last?.items)! {
                    UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                        item?.alpha = 1
                    })
                }
                UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                    self.viewControllers.last?.backItem!.alpha = 1
                })
            }
        }
    }
    
    func moveContentView(to point: CGPoint) {
        contentPoint = point
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(rootViewController: nil) //[XFATRootViewController new]
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(rootViewController: nil)
    }
    
    override func loadView() {
        super.loadView()
        contentPoint = XFATLayoutAttributes.cotentViewDefaultPoint()
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth()))
        contentView?.center = contentPoint
        contentView?.layer.cornerRadius = 14
        if let contentView = contentView {
            view.addSubview(contentView)
        }
        
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView?.frame = contentView?.bounds ?? CGRect.zero
        effectView?.layer.cornerRadius = XFATLayoutAttributes.cornerRadius()
        effectView?.layer.masksToBounds = true
        if let effectView = effectView {
            contentView?.addSubview(effectView)
        }
        
        contentItem = XFATItemView.item(with: XFATItemViewType.system)
        contentItem?.center = contentPoint
        if let contentItem = contentItem {
            view.addSubview(contentItem)
        }
        
        view.frame = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
        contentAlpha = XFATLayoutAttributes.inactiveAlpha()
        contentPoint = CGPoint(x: XFATLayoutAttributes.itemImageWidth() / 2, y: XFATLayoutAttributes.itemImageWidth() / 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let spreadGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(XFATNavigationController.spread))
        let shrinkGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(XFATNavigationController.shrink))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(XFATNavigationController.panGestureAction(_:)))
        contentItem?.addGestureRecognizer(spreadGestureRecognizer)
        view.addGestureRecognizer(shrinkGestureRecognizer)
        contentItem?.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Accessor
    
    func setViewControllers(_ viewControllers: [XFATViewController]?) {
//        var viewControllers = viewControllers
        self.viewControllers = viewControllers!
    }
    
    // MARK: - Animition
    
    // MARK: - Timer
    func beginTimer() {
        timer = Timer(timeInterval: TimeInterval(XFATLayoutAttributes.activeDuration()), target: self, selector: #selector(XFATNavigationController.timerFired), userInfo: nil, repeats: false)
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFired() {
        UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
            self.contentAlpha = XFATLayoutAttributes.inactiveAlpha()
        })
        stopTimer()
    }
    
    // MARK: - Action
//    static let panGestureActionPointOffset: CGPoint = {
//        var pointOffset = UIGestureRecognizer?.location(in: self.contentItem)
//        return pointOffset
//    }()

    private var panGestureActionOnceToken: Bool = false
    private var panGestureActionPointOffset : CGPoint?
    
    @objc func panGestureAction(_ gestureRecognizer: UIGestureRecognizer?) {
        
        if !panGestureActionOnceToken {
            panGestureActionPointOffset = gestureRecognizer?.location(in: view)
            panGestureActionOnceToken = true
        }
        let point: CGPoint? = gestureRecognizer?.location(in: view)
        // `dispatch_once()` call was converted to a static variable initializer
        
        if gestureRecognizer?.state == .began {
            invokeActionBeginDelegate()
            stopTimer()
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                self.contentAlpha = 1
            })
        } else if gestureRecognizer?.state == .changed {
            contentPoint = CGPoint(x: (point?.x ?? 0.0) + XFATLayoutAttributes.itemImageWidth() / 2 - panGestureActionPointOffset!.x, y: (point?.y ?? 0.0) + XFATLayoutAttributes.itemImageWidth() / 2 - panGestureActionPointOffset!.y)
        } else if gestureRecognizer?.state == .ended || gestureRecognizer?.state == .cancelled || gestureRecognizer?.state == .failed {
            UIView.animate(withDuration: TimeInterval(XFATLayoutAttributes.animationDuration()), animations: {
                self.contentPoint = self.stickToPointByHorizontal()
            }) { finished in
                self.invokeActionEndDelegate()
                self.panGestureActionOnceToken = false
                self.beginTimer()
            }
        }
    }
    
    // MARK: - StickToPoint
    func stickToPointByHorizontal() -> CGPoint {
        let screen: CGRect = UIScreen.main.bounds
        let center: CGPoint = contentPoint
        if center.y < center.x && center.y < -center.x + screen.size.width {
            var point = CGPoint(x: center.x, y: XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2)
            point = makePointValid(point)
            return point
        } else if center.y > center.x + screen.size.height - screen.size.width && center.y > -center.x + screen.size.height {
            var point = CGPoint(x: center.x, y: screen.height - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin())
            point = makePointValid(point)
            return point
        } else {
            if center.x < screen.size.width / 2 {
                var point = CGPoint(x: XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2, y: center.y)
                point = makePointValid(point)
                return point
            } else {
                var point = CGPoint(x: screen.width - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin(), y: center.y)
                point = makePointValid(point)
                return point
            }
        }
    }
    
    func makePointValid(_ point: CGPoint) -> CGPoint {
        var point = point
        let screen: CGRect = UIScreen.main.bounds
        if point.x < XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2 {
            point.x = XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2
        }
        if point.x > screen.width - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin() {
            point.x = screen.width - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin()
        }
        if point.y < XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2 {
            point.y = XFATLayoutAttributes.margin() + XFATLayoutAttributes.itemImageWidth() / 2
        }
        if point.y > screen.height - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin() {
            point.y = screen.height - XFATLayoutAttributes.itemImageWidth() / 2 - XFATLayoutAttributes.margin()
        }
        return point
    }
    
    // MARK: - Private
    func invokeActionBeginDelegate() {
        if !show && delegate != nil && delegate?.responds(to: #selector(XFATNavigationControllerDelegate.navigationController(_:actionBeginAt:))) ?? false {
            delegate?.navigationController(self, actionBeginAt: contentPoint)
        }
    }
    
    func invokeActionEndDelegate() {
        if delegate != nil && delegate?.responds(to: #selector(XFATNavigationControllerDelegate.navigationController(_:actionEndAt:))) ?? false {
            delegate?.navigationController(self, actionEndAt: contentPoint)
        }
    }
}
