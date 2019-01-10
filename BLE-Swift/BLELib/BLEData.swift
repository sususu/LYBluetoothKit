//
//  BLEData.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/14.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

public enum BLEDataType {
    case normal
    case response
    case addressBook
}

enum BLEDataState {
    case plain
    case sending
    case sent
    case sendFailed
    case recving
    case recved
    case recvFailed
    case timeout
}

@objcMembers class BLEData: NSObject {

    var sendData:Data
    var recvData:Data?
    var recvDatas:[Data]?
    var recvDataLength:Int = 0
    var recvDataCount:Int = 1
    var type:BLEDataType = .normal
    var sendToUuid: String?
    var recvFromUuid: String?
    var state:BLEDataState = .plain {
        didSet {
            stateRaw = "state change:\(state)"
        }
    }
    dynamic private(set) var stateRaw:String = ""
    
    var error:BLEError?
    
    init(sendData:Data, type:BLEDataType) {
        self.sendData = sendData
        self.type = type
        super.init()
    }
}
