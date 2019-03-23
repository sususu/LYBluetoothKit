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
    
    public func setDeviceID(id: String, boolCallback: BoolCallback?, toDeviceName deviceName: String? = nil) -> BLETask? {
        
        guard let idData = id.data(using: .utf8) else {
            boolCallback?(false, BLEError.taskError(reason: .paramsError))
            return nil
        }
        
        var len = id.count + 4
        var data = Data(bytes: [0x6f, 0xff, 0x71])
        data.append(bytes: &len, count: 2);
        data.append(contentsOf: [0x24, 0x24])
        data.append(idData)
        data.append(contentsOf: [0x26, 0x26, 0x8f])
        return send(data: data, boolCallback: boolCallback, toDeviceName: deviceName)
    }
    
    
    public func getFirmwareVersionWithBuild(stringCallback:StringCallback?, toDeviceName deviceName:String?) -> BLETask? {
        return getVersionStr(forType: 5, stringCallback: stringCallback, toDeviceName: deviceName)
    }
    
    public func getFirmwareVersion(stringCallback:StringCallback?, toDeviceName deviceName:String?) -> BLETask? {
        return getVersionStr(forType: 1, stringCallback: stringCallback, toDeviceName: deviceName)
    }
    
    public func getDateFirmwareVersion(stringCallback:StringCallback?, toDeviceName deviceName:String?) -> BLETask? {
        return getVersionStr(forType: 6, stringCallback: stringCallback, toDeviceName: deviceName)
    }
    
    
    public func getVersionStr(forType type: UInt8, stringCallback:StringCallback?, toDeviceName deviceName: String?) -> BLETask? {
        let data = Data(bytes: [0x6f, 0x03, 0x70, 0x01, 0x00, type, 0x8f])
        return send(data: data, stringCallback: stringCallback, toDeviceName: deviceName)
    }
    
    public func resetDevice(boolCallback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data(bytes: [0x6F,0x0D,0x71,0x01,0x00,0x00,0x8F])
        return send(data: data, boolCallback: boolCallback, toDeviceName: deviceName)
    }
    
}
