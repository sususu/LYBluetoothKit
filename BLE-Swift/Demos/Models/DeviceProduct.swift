//
//  DeviceProduct.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceProduct: Codable {
    var Id: String = ""
    var name: String
    var createTime: TimeInterval
    var testGroups: [DeviceTestGroup]?
    
    init(name: String, createTime: TimeInterval) {
        self.name = name
        self.createTime = createTime
    }
}
