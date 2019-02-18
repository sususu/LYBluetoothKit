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
    
    func isEmail() -> Bool {
        
        let pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
            return matches.count > 0
        } catch {
            return false
        }
    }
    
    func hasIllegalCharacters() -> Bool {
        let pattern = "^[A-Za-z0-9_.]+$"
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
            return matches.count == 0
        } catch {
            return true
        }
    }
}
