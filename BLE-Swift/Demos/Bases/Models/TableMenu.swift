//
//  Menu.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/17.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

enum MenuType {
    case method
    case push
    case present
}

class TableMenu: NSObject {
    
    var name:String
    var type:MenuType
    var operation:String
    var descri:String
    
    init(name:String, type:MenuType = .method, operation:String = "", descri:String = "") {
        self.name = name
        self.type = type
        self.operation = operation
        self.descri = descri
        super.init()
    }
}
