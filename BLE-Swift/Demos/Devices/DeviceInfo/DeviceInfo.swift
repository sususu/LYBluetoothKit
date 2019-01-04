//
//  DeviceInfo.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum DeviceInfoType {
    case advertisementData
    case service
    case characteristic
}

class DeviceInfo: NSObject {

    var type: DeviceInfoType
    var id: String = ""
    var uuid: String = ""
    var name: String = ""
    var properties: String = ""
    var subItems = Array<DeviceInfo>()
    
    init(type: DeviceInfoType,
         uuid: String = "",
         name: String = "",
         properties:String = "",
         id: String = "")
    {
        self.type = type
        self.id = id
        self.uuid = uuid
        self.name = name
        self.properties = properties
    }
}
