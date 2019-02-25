//
//  ProtocolObj.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolObj {

    var id: Int
    var name: String
    var updateTime: Int = (Int)(Date().timeIntervalSince1970)
    var proto: String = ""
    var userName: String = ""
    var userId: Int = -1
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
