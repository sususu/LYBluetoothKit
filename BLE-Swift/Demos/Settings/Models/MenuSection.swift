//
//  MenuSection.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class MenuSection {

    var title: String
    var footerTitle: String?
    var rows: [MenuRow]?
    
    init(title: String) {
        self.title = title
    }
    
    var titleHeight: CGFloat = 20
    var footerHeight: CGFloat = 0.001
}
