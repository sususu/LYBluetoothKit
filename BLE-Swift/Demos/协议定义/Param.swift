//
//  Param.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum ParamType: Int, Codable {
    case int
    case string
    case bool
    case array
    case object
    case time
    case date
    case datetime
    case enumeration
}

class Param: Codable {
    var type: ParamType = .int
    var label: String?
    var value: String?
    var enumNameArr: [String]?
    var enumValueArr: [Int]?
    
    init(type: ParamType) {
        self.type = type
    }
}
