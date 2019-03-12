//
//  CircleGroup.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class CircleGroup: Codable, Equatable {
    
    var repeatCount = 1
    var name = ""
    
    var tests: [CircleTest] = []
    
    static func == (lhs: CircleGroup, rhs: CircleGroup) -> Bool {
        return lhs.name == rhs.name
    }
}
