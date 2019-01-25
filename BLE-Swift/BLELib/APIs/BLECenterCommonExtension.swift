//
//  BLECenterCommonExtension.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/15.
//  Copyright © 2018 ss. All rights reserved.
//

import Foundation

extension BLECenter {
    
    public func send(data:Data, dataArrayCallback: DataArrayCallback?, toDeviceName:String?)->BLETask? {
        let d = BLEData(sendData: data, type: .normal)
        return send(data: d, callback: { (recv, err) in
            if err != nil {
                dataArrayCallback?(nil, err)
            } else {
                if let recvData = recv as? BLEData {
                    dataArrayCallback?(recvData.recvDatas, nil)
                } else {
                    dataArrayCallback?(nil, BLEError.taskError(reason: .dataError))
                }
            }
        })
    }
    
    
    public func send(data:Data, boolCallback:BoolCallback?, toDeviceName:String?)->BLETask? {
        let d = BLEData(sendData: data, type: .normal)
        return send(data: d, callback: { (recv, err) in
            if err != nil {
                boolCallback?(false, err)
            } else {
                var bool = false
                var err: BLEError? = nil
                if let recvData = recv as? BLEData, let bytes = recvData.recvData?.bytes {
                    
                    let cmd = recvData.sendData.bytes[1]
                    let code = recvData.sendData.bytes[2]
                    
                    if bytes.count == 2 &&
                        (code == bytes[0] || cmd == bytes[0]) {
                        bool = (bytes[1] == 0)
                    } else {
                        err = BLEError.taskError(reason: .dataError)
                        print("send data is invalid")
                    }
            
                }
                boolCallback?(bool, err)
            }
        }, toDeviceName: toDeviceName)
    }
    
    public func send(data:Data, stringCallback:StringCallback?, toDeviceName:String?)->BLETask? {
        let d = BLEData(sendData: data, type: .normal)
        return send(data: d, callback: { (recv, err) in
            if err != nil {
                stringCallback?(nil, err)
            } else {
                var str:String? = nil
                var err:BLEError? = nil
                if let recvData = recv as? BLEData, let dd = recvData.recvData {
                    str = String(bytes: dd, encoding: String.Encoding.utf8)
                } else {
                    err = BLEError.taskError(reason: .dataError)
                }
                stringCallback?(str, err)
            }
        }, toDeviceName: toDeviceName)
    }
    
    public func send(data:Data, intCallback:IntCallback?, toDeviceName:String?)->BLETask? {
        let d = BLEData(sendData: data, type: .normal)
        return send(data: d, callback: { (recv, err) in
            var result = -1
            if err != nil {
                intCallback?(result, err)
            } else {
                var err:BLEError? = nil
                if let recvData = recv as? BLEData, let bytes = recvData.recvData?.bytes {
                    result = 0
                    for (i, v) in bytes.enumerated() {
                        result += Int(v << (i * 8))
                    }
                } else {
                    err = BLEError.taskError(reason: .dataError)
                }
                intCallback?(result, err)
            }
        }, toDeviceName: toDeviceName)
    }
}
