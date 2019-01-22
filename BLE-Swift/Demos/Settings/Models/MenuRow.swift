//
//  MenuRow.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class MenuRow {
    var title: String
    var icon: String?
    
    var selector: String?
    var pushVC: String?
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, icon: String?, selector: String?, pushVC: String?) {
        self.init(title: title)
        self.icon = icon
        self.selector = selector
        self.pushVC = pushVC
    }
}
