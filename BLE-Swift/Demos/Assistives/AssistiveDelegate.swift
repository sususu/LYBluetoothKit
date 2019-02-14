//
//  AssistiveDelegate.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/2/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class AssistiveDelegate: NSObject, XFXFAssistiveTouchDelegate {
    
    static let sharedInstance = AssistiveDelegate()
    
    override init() {
        super.init()
        let assistiveTouch:XFAssistiveTouch = XFAssistiveTouch.sharedInstance();
        assistiveTouch.delegate = (self as XFXFAssistiveTouchDelegate);
    }
    
    public func showAssistance() -> Void {
        XFAssistiveTouch.sharedInstance().show();
    }
    
    func numberOfItems(in viewController: XFATViewController?) -> Int {
        return 2;
    }
    
    func viewController(_ viewController: XFATViewController?, itemViewAtPosition position: XFATPosition?) -> XFATItemView? {
        switch position?.index {
        case 0:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 1:
            return XFATItemView.item(with: XFATItemViewType.back);
        case 2:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 3:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 4:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 5:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 6:
            return XFATItemView.item(with: XFATItemViewType.star);
        case 7:
            return XFATItemView.item(with: XFATItemViewType.star);
        default:
            return XFATItemView.item(with: XFATItemViewType.none);
        }
    }
    
    func viewController(_ viewController: XFATViewController?, didSelectedAtPosition position: XFATPosition?) {
        
        /*  //这段代码是点击后会再跳转一次，但是有问题，先不管
         let arr:NSMutableArray = NSMutableArray();
         for i in 0...Int(position!.index) {
         let itemView:XFATItemView = XFATItemView.item(with: XFATItemViewType(rawValue: XFATItemViewType.count.rawValue+i)!)
         arr.add(itemView)
         }
         let vc:XFATViewController = XFATViewController.init(items: (arr.copy() as! [XFATItemView]))
         XFAssistiveTouch.sharedInstance().navigationController?.push(vc, atPisition: position)
         */
        
        var rootVC = UIApplication.shared.delegate?.window!!.rootViewController!
        
        while ((rootVC?.presentedViewController) != nil) {
            rootVC = rootVC?.presentedViewController
        }
        
        viewController?.navigationController?.shrink();
        
        switch position?.index {
        case 0:
            
            if rootVC is LYNavigationController && (rootVC as! LYNavigationController).viewControllers.first is LogRecordViewController {
                return;
            }
            
            let vc: LogRecordViewController = LogRecordViewController()
            let nav = LYNavigationController.init(rootViewController: vc)
            
            rootVC!.present(nav, animated: true, completion: nil)
            let logger = Logger.shared();
            
            
            let arr:NSMutableArray = NSMutableArray();
            arr.add("1");
            logger.log(arr);
            logger.log("123", elements: Logger.ElementOptions.All);

//            print("Hello");
//            print(arr);
//            
//            NSLog("format %@", arr);
            
            break
            
        case 1:
//            rootVC?.dismiss(animated: true, completion: nil)
            break
        default: break
            
        }
        
    }
}

