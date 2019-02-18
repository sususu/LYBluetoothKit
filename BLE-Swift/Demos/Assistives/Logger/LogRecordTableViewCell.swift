//
//  LogRecordTableViewCell.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/14.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class LogRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction))
        self.addGestureRecognizer(longPress);
        
    }

    @objc func longPressAction(sender: UILongPressGestureRecognizer) -> Void {
        
        if sender.state == .began {
            self.becomeFirstResponder() // 这句很重要
            let menuController = UIMenuController.shared
            let copyItem = UIMenuItem.init(title: "Copy", action: #selector(copyAction))
            menuController.menuItems = [copyItem]
//            let rect = CGRect(x: 100, y: 100, width: 100, height: 100)
            
            menuController.setTargetRect(frame, in: superview!)
            menuController.setMenuVisible(true, animated: true)
        }
        
    }
    
    @objc func copyAction() -> Void {
        UIPasteboard.general.string = self.label.text;
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if [#selector(copyAction)].contains(action) {
            return true
        }
        return false
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
