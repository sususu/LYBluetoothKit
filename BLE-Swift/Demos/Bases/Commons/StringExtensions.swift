//
//  StringExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/16.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

extension String {
    func size(withFont font:UIFont) -> CGSize {
        if self.count == 0 {
            return CGSize.zero
        }
        return (self as NSString).size(withAttributes: [.font : font])
    }
}
