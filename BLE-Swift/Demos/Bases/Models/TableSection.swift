//
//  TableSection.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/17.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

class TableSection: NSObject {
    var name:String
    var menus:[TableMenu] = []
    
    init(name:String, menus:[TableMenu] = []) {
        self.name = name
        self.menus = menus
        super.init()
    }
}
