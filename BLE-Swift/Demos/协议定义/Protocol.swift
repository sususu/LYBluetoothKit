//
//  Protocol.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class Protocol: NSObject {
    var name = ""
    var code = ""
    var summary = ""
    var cmd = ""
    var returnFormat = ReturnFormat()
}

extension Protocol {
    var isBoolReturn: Bool {
        get {
            if returnFormat.type == "bool" {
                return true
            } else {
                return false
            }
        }
    }
    
    var isStringReturn: Bool {
        get {
            if returnFormat.type == "string" {
                return true
            } else {
                return false
            }
        }
    }
    
    var isDictionaryReturn: Bool {
        get {
            if returnFormat.type == "object" {
                return true
            } else {
                return false
            }
        }
    }
    
    var isArrayReturn: Bool {
        get {
            if returnFormat.type == "array" {
                return true
            } else {
                return false
            }
        }
    }
}
