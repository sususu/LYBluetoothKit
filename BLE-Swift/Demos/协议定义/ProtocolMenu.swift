//
//  ProtocolMenu.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenu: NSObject {
    var name = ""
    var icon = ""
    var summary = ""
    var protocols = Array<Protocol>()
    
    init(name: String) {
        self.name = name
    }
}
