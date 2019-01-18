//
//  CmdUnit.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/16.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum CmdUnitType {
    case cmd
    case constant
    case variable
    case placeHolder
}

public class CmdUnit: NSObject {
    var type: CmdUnitType = .cmd
    var name = ""
    var valueStr: String?
    var param: Param?
}
