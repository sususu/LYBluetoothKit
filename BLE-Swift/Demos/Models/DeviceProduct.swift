//
//  DeviceProduct.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceProduct: NSObject, Codable, NSCopying {
    
    var Id: String = ""
    var name: String
    var bleName: String = ""
    var createTime: TimeInterval
    var testGroups: [DeviceTestGroup] = []
    //自动测单元
    var ziceUnits: [DeviceTestUnit] = []
    //屏蔽箱测试
    var pbxCsUnits: [DeviceTestUnit] = []
    
    init(name: String, createTime: TimeInterval) {
        self.name = name
        self.createTime = createTime
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let ndp = DeviceProduct(name: self.name, createTime: self.createTime)
        ndp.bleName = self.bleName
        ndp.testGroups = self.testGroups
        return ndp
    }
}
