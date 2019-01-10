//
//  File.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/9.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

extension String {
    var lastPathComponent: String {
        get {
            return self.components(separatedBy: "/").last ?? self
        }
    }
    
    func stringByAppending(pathComponent: String) -> String {
        if self.count == 0 {
            return pathComponent
        }
        if self.suffix(1) == "/" {
            return self + pathComponent
        } else {
            return self + "/" + pathComponent
        }
    }
}
