//
//  TableViewCellExtension.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/14.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class func getNib() -> UINib {
        
        let nibName = NSStringFromClass(self).components(separatedBy: ".").last
        
        return UINib.init(nibName: nibName!, bundle: nil)
    }
    
    class func getReuseIdentifier() -> String {
        let identifier = NSStringFromClass(self) + "Mark"
        return identifier;
    }
}
