//
//  OtaConfig.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum OtaPlatform: Int, Codable {
    case apollo
    case nordic
}

struct OtaConfig: Codable {

    var id = 0
    var autoReset = false
    var platform: OtaPlatform = .apollo
    var createTime: TimeInterval = Date().timeIntervalSince1970
    var name = ""
    var type = ""
    var batchId = ""
    var prefix = ""
    var deviceName = ""
    var firmwares: [Firmware] = []
    
}
