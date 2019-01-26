//
//  ProtocolMenu.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenu: Codable {
    var name = ""
    var icon = ""
    var summary = ""
    var createTime: TimeInterval
    var protocols = Array<Protocol>()

    init(name: String, createTime: TimeInterval) {
        self.name = name
        self.createTime = createTime
    }
}
