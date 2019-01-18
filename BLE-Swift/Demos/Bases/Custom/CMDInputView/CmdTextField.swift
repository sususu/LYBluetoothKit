//
//  CmdTextField.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/17.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class CmdTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

}
