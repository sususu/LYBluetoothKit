//
//  OtaPrefix.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

struct OtaPrefix: Codable {
    
    var deviceName = ""
    var bleName = ""
    var prefix = ""
    
    init(deviceName: String, bleName: String, prefix: String) {
        self.deviceName = deviceName
        self.bleName = bleName
        self.prefix = prefix
    }
}
