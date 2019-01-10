//
//  OtaDataModel.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

public enum OtaDataType: Int, Codable {
    case platform = 1
    case touchPanel
    case heartRate
    case picture
    case language
    case freeScale
}

public struct OtaDataModel : Codable {
    var type: OtaDataType
    var data: Data
    
    init(type: OtaDataType, data: Data) {
        self.type = type
        self.data = data
    }
}
