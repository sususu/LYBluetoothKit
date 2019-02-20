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
    var returnCount = 1
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
            return returnFormat.type == .bool
        }
    }
    
    var isStringReturn: Bool {
        get {
            return returnFormat.type == .string
        }
    }
    
    var isSplitReturn: Bool {
        get {
            return returnFormat.type == .split
        }
    }
    
    var paramUnits: [CmdUnit]? {
        var units = [CmdUnit]()
        for unit in cmdUnits {
            if unit.type == .variable && unit.param != nil {
                units.append(unit)
            }
        }
        return units;
    }
}
