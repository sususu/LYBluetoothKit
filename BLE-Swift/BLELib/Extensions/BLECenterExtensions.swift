//
//  BLECenterExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

extension BLECenter {
    
    /// 选择所有连接设备中的第一个
    var connectedDevice: BLEDevice? {
        if connectedDevices.count == 0
        {
            return nil
        }
        return connectedDevices[0]
    }
}
