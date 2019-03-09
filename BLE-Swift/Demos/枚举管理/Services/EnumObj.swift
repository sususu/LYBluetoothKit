//
//  EnumObj.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class EnumObj: Codable, Equatable {

    var name: String = ""
    var labelArr: [String] = []
    var valueArr: [Int] = []
    

    static func == (lhs: EnumObj, rhs: EnumObj) -> Bool {
        return lhs.name == rhs.name
    }
}
