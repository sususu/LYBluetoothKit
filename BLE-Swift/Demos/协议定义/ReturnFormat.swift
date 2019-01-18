//
//  ReturnFormat.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ReturnFormat: Codable {

    var type = "bool"
    var length = 0
    var byteFlag = 0
    
    var subFormat: ReturnFormat?
    
}

func boolReturnFormat() -> ReturnFormat {
    return ReturnFormat()
}

func stringReturnFormat() -> ReturnFormat {
    let rf = ReturnFormat()
    rf.type = "string"
    return rf;
}
