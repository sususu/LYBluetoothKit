//
//  ReturnFormat.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit


enum ReturnFormatKind: Int, Codable {
    case bool = 0
    case string
    case split
    case tlv
}

class ReturnFormat: Codable {

    var type: ReturnFormatKind = .bool
    var length = 0
    var byteFlag = 0
    var label = ""
    
    var subFormat: ReturnFormat?
    
    
    var typeName: String {
        get {
            switch type {
            case .bool:
                return "Bool"
            case .string:
                return "String"
            case .split:
                return "按字节拆分"
            case .tlv:
                return "类型-长度-值"
            }
        }
    }
}

func boolReturnFormat() -> ReturnFormat {
    return ReturnFormat()
}

func stringReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = .string
    return rf
}

func splitReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = .split
    return rf
}

func tlvReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = .tlv
    return rf
}
