//
//  BLECenterCommonExtension.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/15.
//  Copyright © 2018 ss. All rights reserved.
//

import Foundation

extension BLECenter {
    public func send(data:Data, boolCallback:BoolCallback?, toDeviceName:String?)->BLETask? {
        let d = BLEData(sendData: data, type: .normal)
        return send(data: d, callback: { (recv, err) in
            if err != nil {
                boolCallback?(false, err)
            } else {
                var bool = false
                if let recvData = recv as? BLEData, let bytes = recvData.recvData?.bytes {
                    
                    if bytes.count == 2 && recvData.sendData.bytes[2] == bytes[0] {
                        bool = (bytes[1] == 0)
                    } else {
                        print("send data is invalid")
                    }
            
                }
                boolCallback?(bool, nil)
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
                var err:NSError? = nil
                if let recvData = recv as? BLEData, let dd = recvData.recvData {
                    str = String(bytes: dd, encoding: String.Encoding.utf8)
                } else {
                    err = NSError(domain: Domain.data, code: Code.dataError, userInfo: nil)
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
                var err:NSError? = nil
                if let recvData = recv as? BLEData, let bytes = recvData.recvData?.bytes {
                    result = 0
                    for (i, v) in bytes.enumerated() {
                        result += Int(v << (i * 8))
                    }
                } else {
                    err = NSError(domain: Domain.data, code: Code.dataError, userInfo: nil)
                }
                intCallback?(result, err)
            }
        }, toDeviceName: toDeviceName)
    }
}
