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
             boolCallback: ((Bool?)->Void)?,
             stringCallback: ((String?)->Void)?,
             dictCallback: ((Dictionary<String, Any>?)->Void)?,
             dictArrayCallback: ((Array<Dictionary<String, Any>>?)->Void)?,
             errorCallback: ((BLEError)->Void)?) {
        
        if let sendData = getCmdData(pcl: pcl) {
            BLECenter.shared.send(data: sendData, dataArrayCallback: { (datas, err) in
                
                if err != nil {
                    errorCallback?(err!)
                    return
                }
                
                if pcl.isBoolReturn {
                    
                }
                else if pcl.isStringReturn {
                    if let arr = datas, arr.count > 0 {
                        let str = String(bytes: arr[0], encoding: String.Encoding.utf8)
                        stringCallback?(str)
                    }
                }
                
            }, toDeviceName: nil)
        } else {
            errorCallback?(BLEError.taskError(reason: .paramsError))
        }
        
    }
    
    func getCmdData(pcl: Protocol) -> Data? {
//        return pcl.cmd.hexadecimal
        return nil
    }
    
}
