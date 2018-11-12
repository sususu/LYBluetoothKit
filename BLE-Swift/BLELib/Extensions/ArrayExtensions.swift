//
//  ArrayExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/14.
//  Copyright © 2018年 ss. All rights reserved.
//
#if canImport(Foundation)
import Foundation

public extension Array where Element : Equatable {
    mutating func remove(_ object: Element) {
        self = self.filter { $0 != object }
    }
}

#endif
