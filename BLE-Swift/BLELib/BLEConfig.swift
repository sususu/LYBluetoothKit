//
//  BLEConfig.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/14.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

public class BLEConfig: NSObject {
    public static let shared = BLEConfig()
    
    var mtu:Int = 20
    var shouldSend03End = true
    
    var sendUUID:[BLEDataType : String] = [:]
    var recvUUID:[BLEDataType : String] = [:]
    var heartRateUUID = "2A37"
    
    public override init() {
        super.init()
        sendUUID[.normal] = UUID.c8001
        recvUUID[.normal] = UUID.c8002
    }
}
