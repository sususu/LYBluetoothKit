//
//  CircleTest.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum CircleTestType: Int, Codable {
    case cmd
    case connect
    case disconnect
}

class CircleTest: Codable {

    var type: CircleTestType = .cmd
    var span: TimeInterval = 0
    var name = ""
    var hexData = ""
    
    
}
