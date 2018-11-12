//
//  BLEToDo.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/8.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

struct ToDo {
    static let nothing = 0
    static let disconnect = 1
    static let scan = 2
    static let connect = 3
    static let autoConnect = 4
    static let otaConnect = 5
}

class BLEToDo: NSObject {
    var cmd:Int = ToDo.nothing
    var block:EmptyBlock
    
    init(cmd:Int, block:@escaping EmptyBlock) {
        self.block = block
        self.cmd = cmd
    }
}
