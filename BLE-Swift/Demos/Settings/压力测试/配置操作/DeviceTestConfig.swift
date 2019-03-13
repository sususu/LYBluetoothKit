//
//  DeviceTestConfig.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestConfig: Codable, Equatable {
    
    var name: String
    var groups: [CircleGroup]

    init(name: String, groups: [CircleGroup]) {
        self.name = name
        self.groups = groups
    }
    
    static func == (lhs: DeviceTestConfig, rhs: DeviceTestConfig) -> Bool {
        return lhs.name == rhs.name
    }
    

}
