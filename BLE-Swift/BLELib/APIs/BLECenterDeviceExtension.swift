//
//  BLECenterDeviceExtension.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/15.
//  Copyright © 2018 ss. All rights reserved.
//

import Foundation
extension BLECenter {
    public func getDeviceID(stringCallback:StringCallback?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data(bytes: [0x6f, 0x02, 0x70, 0x01, 0x00, 0x00, 0x8f])
        return send(data: data, stringCallback: stringCallback, toDeviceName: deviceName)
    }
}
