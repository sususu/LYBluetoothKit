//
//  DeviceTestUnit.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestUnit: Codable {
    var name: String
    var createTime: TimeInterval
    // 是不是自测
    var isZiCe: Bool = false
    // 测试结果
    var ceshiResult: String = ""
    // 测试时间
    var ceshiTime: TimeInterval = 0
    var prol: [Protocol]!
    
    init(name: String, createTime: TimeInterval) {
        self.name = name
        self.createTime = createTime
    }
}
