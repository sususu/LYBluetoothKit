//
//  XFATViewController.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
class XFATViewController: UIResponder {
    
    public var navigationController: XFATNavigationController?

    required init(items: [XFATItemView]?) {
        super.init()
        
        if let items = items {
            self.items = items
        }
        backItem = XFATItemView.item(with: XFATItemViewType.back)
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(XFATViewController.backGesture(_:)))
        backItem?.addGestureRecognizer(backGesture)
        
    }
    
    func loadView() {
        items = [XFATItemView(), XFATItemView(), XFATItemView(), XFATItemView(), XFATItemView(), XFATItemView(), XFATItemView(), XFATItemView()]
    }
    
    func viewDidLoad() {
    }
    
    var backItem: XFATItemView?
    
    private var _items: [XFATItemView] = []
    var items: [XFATItemView] {
        get {
//            #if false
            if _items.count == 0 {
                loadView()
                viewDidLoad()
            }
//            #endif
            return _items
        }
        set(items) {
            if (items.count ) > XFATLayoutAttributes.maxCount() {
                if let subarray = (items as NSArray?)?.subarray(with: NSRange(location: 0, length: XFATLayoutAttributes.maxCount())) as? [XFATItemView] {
                    _items = subarray
                }
            } else {
//                if let items = items {
                    _items = items
//                }
            }
            for i in 0..<min(_items.count, _items.count) {
                let item: XFATItemView = _items[i]
                item.position = XFATPosition(count: _items.count, index: i)
            }
        }
    }
    
    override convenience init() {
        self.init(items: nil)
    }
    
    // MARK: - Accessor
    
    // MARK: - LoadView
    
    // MARK: - Action
    @objc func backGesture(_ backGesture: UITapGestureRecognizer?) {
        navigationController?.popViewController()
    }
}
