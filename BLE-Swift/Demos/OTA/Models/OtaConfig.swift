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
    case tlsr
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
    var deviceNamePrefix = ""
    var signalMin = -100
    var upgradeCountMax = 5
    var otaCount = 0
    var needReset = false
    var firmwares: [Firmware] = []
    
    
    func getFirmwares(byType type: OtaDataType) -> [Firmware] {
        var arr = [Firmware]()
        for fm in firmwares {
            if fm.type == type {
                arr.append(fm)
            }
        }
        return arr
    }
}
