//
//  XFATRootViewController.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
@objc protocol XFATRootViewControllerDelegate: NSObjectProtocol {
    func numberOfItems(in viewController: XFATRootViewController?) -> Int
    func viewController(_ viewController: XFATRootViewController?, itemViewAtPosition position: XFATPosition?) -> XFATItemView?
    func viewController(_ viewController: XFATRootViewController?, didSelectedAtPosition position: XFATPosition?)
}

class XFATRootViewController: XFATViewController {
    weak var delegate: XFATRootViewControllerDelegate?
    
    override func loadView() {
        super.loadView()
        var itemsArray: [XFATItemView] = []
        var count: Int = 0
        if delegate != nil && delegate?.responds(to: #selector(XFATRootViewControllerDelegate.numberOfItems(in:))) ?? false {
            count = delegate?.numberOfItems(in: self) ?? 0
            count = min(max(0, count), XFATLayoutAttributes.maxCount())
        }
        for i in 0..<count {
            var item: XFATItemView?
            if delegate != nil && delegate?.responds(to: #selector(XFATRootViewControllerDelegate.viewController(_:itemViewAtPosition:))) ?? false {
                item = delegate?.viewController(self, itemViewAtPosition: XFATPosition(count: count, index: i))
            }
            item = item != nil ? item : XFATItemView()
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(XFATRootViewController.tapGestureAction(_:)))
            item?.addGestureRecognizer(tapGestureRecognizer)
            if let item = item {
                itemsArray.append(item)
            }
        }
        items = itemsArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad");
    }
    
    // MARK: - Action
    @objc func tapGestureAction(_ tapGestureRecognizer: UITapGestureRecognizer?) {
        if delegate != nil && delegate?.responds(to: #selector(XFATRootViewControllerDelegate.viewController(_:didSelectedAtPosition:))) ?? false {
            let item = tapGestureRecognizer?.view as? XFATItemView
            delegate?.viewController(self, didSelectedAtPosition: item?.position)
        }
    }
}
