//
//  BLEDeviceExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

var kBLEDeviceIsOtaingKey = 100001

extension BLEDevice {
    var isApollo3: Bool {
        return hasService(withUUID: UUID.otaService)
    }
    
    var isOTAing: Bool {
        set {
            objc_setAssociatedObject(self, &kBLEDeviceIsOtaingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            guard let rs = objc_getAssociatedObject(self, &kBLEDeviceIsOtaingKey) else {
                return false
            }
            return rs as! Bool
        }
    }
}
