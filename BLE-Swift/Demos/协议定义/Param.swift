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
}

class Param: Codable {
    var type: ParamType = .int
    var value: String?
    
    init(type: ParamType) {
        self.type = type
    }
}
