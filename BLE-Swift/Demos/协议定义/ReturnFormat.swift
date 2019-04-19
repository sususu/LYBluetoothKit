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
    case hex
}

class ReturnFormat: Codable {

    var type: ReturnFormatKind = .bool
    var length = 0
    var byteFlag = 0
    var label = ""
    var expression: String?
    var ps: String?
    
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
            case .hex:
                return "16进制"
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

func hexReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = .hex
    return rf
}

func splitReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = .split
    return rf
}
