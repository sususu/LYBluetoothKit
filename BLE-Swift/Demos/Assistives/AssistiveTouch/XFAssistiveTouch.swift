//
//  XFAssistiveTouch.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
@objc protocol XFXFAssistiveTouchDelegate: NSObjectProtocol {
    func numberOfItems(in viewController: XFATViewController?) -> Int
    func viewController(_ viewController: XFATViewController?, itemViewAtPosition position: XFATPosition?) -> XFATItemView?
    func viewController(_ viewController: XFATViewController?, didSelectedAtPosition position: XFATPosition?)
}

class XFAssistiveTouch: NSObject, XFATNavigationControllerDelegate, XFATRootViewControllerDelegate {
    
//    static let sharedInstanceVar: Any? = {
//        var sharedInstance = self.init()
//        return sharedInstance
//    }()

    static let sharedInstanceVar: XFAssistiveTouch = XFAssistiveTouch();
    
    class func sharedInstance() -> XFAssistiveTouch {
        // `dispatch_once()` call was converted to a static variable initializer
        return sharedInstanceVar
    }
    
    var assistiveWindow: UIWindow?
    func show() {
        assistiveWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth()))
        print(assistiveWindow as Any);
        print(self);
        assistiveWindow?.center = assistiveWindowPoint
        assistiveWindow?.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        assistiveWindow?.backgroundColor = UIColor.clear
        assistiveWindow?.rootViewController = navigationController
        assistiveWindow?.layer.masksToBounds = true
        makeVisibleWindow()
    }
    
    
    var navigationController: XFATNavigationController?
    weak var delegate: XFXFAssistiveTouchDelegate?
    
    func push(_ viewController: UIViewController?, at targetViewcontroller: UIViewController) {
        if (targetViewcontroller is UINavigationController) {
            if let viewController = viewController {
                (targetViewcontroller as? UINavigationController)?.pushViewController(viewController, animated: true)
            }
        } else {
            if let viewController = viewController {
                targetViewcontroller.present(viewController, animated: true) {
                }
            }
        }
        navigationController?.shrink()
    }
    
    func push(_ viewController: UIViewController?) {
        let topvc: UIViewController? = p_topViewController()
        if (topvc is UINavigationController) {
            if let viewController = viewController {
                (topvc as? UINavigationController)?.pushViewController(viewController, animated: true)
            }
        } else {
            if let viewController = viewController {
                topvc?.present(viewController, animated: true) {
                }
            }
        }
        navigationController?.shrink()
        
    }
    
    private var assistiveWindowPoint = CGPoint.zero
    private var coverWindowPoint = CGPoint.zero
    
    override init() {
        super.init()
        
        let rootViewController = XFATRootViewController()
        rootViewController.delegate = self
        navigationController = XFATNavigationController(rootViewController: rootViewController)
        navigationController?.delegate = self
        assistiveWindowPoint = XFATLayoutAttributes.cotentViewDefaultPoint()
        NotificationCenter.default.addObserver(self, selector: #selector(XFAssistiveTouch.keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func makeVisibleWindow() {
        let keyWindows: UIWindow? = UIApplication.shared.keyWindow
        assistiveWindow?.makeKeyAndVisible()
        if keyWindows != nil {
            keyWindows?.makeKey()
        }
    }
    
    // MARK: - XFATRootViewControllerDelegate
    func numberOfItems(in viewController: XFATRootViewController?) -> Int {
        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.numberOfItems(in:))) ?? false {
            return delegate?.numberOfItems(in: viewController) ?? 0
        } else {
            return 0
        }
    }
    
    func viewController(_ viewController: XFATRootViewController?, itemViewAtPosition position: XFATPosition?) -> XFATItemView? {
        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.viewController(_:itemViewAtPosition:))) ?? false {
            return delegate?.viewController(viewController, itemViewAtPosition: position)
        } else {
            return nil
        }
    }
    
    func viewController(_ viewController: XFATRootViewController?, didSelectedAtPosition position: XFATPosition?) {
        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.numberOfItems(in:))) ?? false {
            delegate?.viewController(viewController, didSelectedAtPosition: position)
        }
    }
//    func numberOfItems(in viewController: XFATViewController?) -> Int {
//        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.numberOfItems(in:))) ?? false {
//            return delegate?.numberOfItems(in: viewController) ?? 0
//        } else {
//            return 0
//        }
//    }
//    
//    func viewController(_ viewController: XFATViewController?, itemViewAtPosition position: XFATPosition?) -> XFATItemView? {
//        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.viewController(_:itemViewAtPosition:))) ?? false {
//            return delegate?.viewController(viewController, itemViewAtPosition: position)
//        } else {
//            return nil
//        }
//    }
//    
//    func viewController(_ viewController: XFATViewController?, didSelectedAtPosition position: XFATPosition?) {
//        if delegate != nil && delegate?.responds(to: #selector(XFXFAssistiveTouchDelegate.numberOfItems(in:))) ?? false {
//            delegate?.viewController(viewController, didSelectedAtPosition: position)
//        }
//    }
    
    // MARK: - XFATNavigationControllerDelegate
    func navigationController(_ navigationController: XFATNavigationController?, actionBeginAt point: CGPoint) {
        coverWindowPoint = CGPoint.zero
        assistiveWindow?.frame = UIScreen.main.bounds
        self.navigationController!.view.frame = UIScreen.main.bounds
        self.navigationController!.moveContentView(to: assistiveWindowPoint)
    }
    
    func navigationController(_ navigationController: XFATNavigationController?, actionEndAt point: CGPoint) {
        assistiveWindowPoint = point
        assistiveWindow?.frame = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
        assistiveWindow?.center = assistiveWindowPoint
        let contentPoint = CGPoint(x: XFATLayoutAttributes.itemImageWidth() / 2, y: XFATLayoutAttributes.itemImageWidth() / 2)
        self.navigationController!.moveContentView(to: contentPoint)
    }
    
    // MARK: - UIKeyboardWillChangeFrameNotification
    @objc func keyboardWillChangeFrame(_ notification: Notification?) {
        
        /*因为动画过程中不能实时修改_assistiveWindowRect,
         *所以如果执行点击操作的话,_assistiveTouchView位置会以动画之前的位置为准.
         *如果执行拖动操作则会有跳动效果.所以需要禁止用户操作.*/
        assistiveWindow?.isUserInteractionEnabled = false
        let info = notification?.userInfo
//        let duration = CGFloat(Float(info?[UIResponder.keyboardAnimationDurationUserInfoKey] ?? 0.0))
        let duration:NSNumber = info?[UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber
        let endKeyboardRect: CGRect? = (info?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        //根据实时位置计算于键盘的间距
        let yOffset: CGFloat = (endKeyboardRect?.origin.y ?? 0.0) - (assistiveWindow?.frame.maxY)!
        
        //如果键盘弹起给_coverWindowPoint赋值
        if (endKeyboardRect?.origin.y ?? 0.0) < UIScreen.main.bounds.height {
            coverWindowPoint = assistiveWindowPoint
        }
        
        //根据间距计算移动后的位置viewPoint
        var viewPoint: CGPoint? = assistiveWindow?.center
        viewPoint?.y += yOffset
        //如果viewPoint在原位置之下,将viewPoint变为原位置
        if (viewPoint?.y ?? 0.0) > coverWindowPoint.y {
            viewPoint?.y = coverWindowPoint.y
        }
        //如果_assistiveWindow被移动,将viewPoint变为移动后的位置
        if coverWindowPoint.equalTo(CGPoint.zero) {
            viewPoint?.y = assistiveWindow?.center.y ?? 0.0
        }
        
        //根据计算好的位置执行动画
        UIView.animate(withDuration: TimeInterval(duration.floatValue), animations: {
            self.assistiveWindow?.center = viewPoint ?? CGPoint.zero
        }) { finished in
            //将_assistiveWindowRect变为移动后的位置并恢复用户操作
            self.assistiveWindowPoint = self.assistiveWindow?.center ?? CGPoint.zero
            self.assistiveWindow?.isUserInteractionEnabled = true
            //使其遮盖键盘
            if Int(UIDevice.current.systemVersion)! < 10 {
                self.makeVisibleWindow()
            }
        }
    }
    
    // MARK: - PushViewController
    
    func p_topViewController() -> UIViewController? {
        return p_topViewController(UIApplication.shared.keyWindow?.rootViewController)
    }
    
    func p_topViewController(_ rootvc: UIViewController?) -> UIViewController? {
        if (rootvc is UITabBarController) {
            let tabvc: UIViewController? = (rootvc as? UITabBarController)?.selectedViewController
            return p_topViewController(tabvc)
        } else {
            var topvc: UIViewController? = rootvc
            while ((topvc?.presentedViewController) != nil) {
                topvc = topvc?.presentedViewController
            }
            return topvc
        }
    }
}
