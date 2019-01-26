//
//  Protocol.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class Protocol: Codable {
    var name = ""
    var code = ""
    var summary = ""
    var cmdUnits = [CmdUnit]()
    var returnFormat = ReturnFormat()
    
    static func cmdFrom(units: [CmdUnit]) -> String {
        var string = ""
        for unit in units {
            string = string + (unit.valueStr ?? "") + "  "
        }
        return string
    }
}

extension Protocol {
    var isBoolReturn: Bool {
        get {
            if returnFormat.type == .bool {
                return true
            } else {
                return false
            }
        }
    }
    
    var isStringReturn: Bool {
        get {
            if returnFormat.type == .string {
                return true
            } else {
                return false
            }
        }
    }
}
