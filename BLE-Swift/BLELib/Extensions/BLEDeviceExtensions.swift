//
//  BLEDeviceExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

extension BLEDevice {
    var isApollo3: Bool {
        return hasService(withUUID: UUID.otaService)
    }
}
