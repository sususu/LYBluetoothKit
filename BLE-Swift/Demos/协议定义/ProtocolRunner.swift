//
//  ProtocolRunner.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit




class ProtocolRunner {

    func run(_ pcl: Protocol,
             boolCallback: ((Bool)->Void)?,
             stringCallback: ((String)->Void)?,
             dictCallback: ((Dictionary<String, Any>)->Void)?,
             dictArrayCallback: ((Array<Dictionary<String, Any>>)->Void)?,
             errorCallback: ((BLEError)->Void)?) {
        
        if let sendData = getCmdData(pcl: pcl) {
            BLECenter.shared.send(data: sendData, recvCount: pcl.returnCount, dataArrayCallback: { (datas, err) in
                
                if err != nil {
                    errorCallback?(err!)
                    return
                }
                
                if pcl.isBoolReturn {
                    var bool = false
                    if let arr = datas, arr.count > 0, arr[0].count >= 2 {
                        bool = (arr[0].bytes[1] == 0)
                    }
                    boolCallback?(bool)
                }
                else if pcl.isStringReturn {
                    var str = ""
                    if let arr = datas, arr.count > 0 {
                        str = String(bytes: arr[0], encoding: String.Encoding.utf8) ?? ""
                    }
                    stringCallback?(str)
                }
                else if pcl.isSplitReturn {
                    
                }
                
            }, toDeviceName: nil)
        } else {
            errorCallback?(BLEError.taskError(reason: .paramsError))
        }
        
    }
    
    func getCmdData(pcl: Protocol) -> Data? {

        var data = Data()
        for unit in pcl.cmdUnits {
            if unit.type == .cmd {
                guard let ud = unit.valueStr?.hexadecimal else {
                    continue
                }
                data.append(ud)
            }
            else if unit.type == .variable {
                guard let param = unit.param else {
                    continue
                }
                if let pd = param.value?.hexadecimal {
                    data.append(pd)
                }
            }
        }
        return data
    }
    
}
