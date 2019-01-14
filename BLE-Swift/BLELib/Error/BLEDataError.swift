//
//  BLEDataError.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum BLEError: Error {
    
    public enum PhoneReason {
        case bluetoothPowerOff
        case bluetoothUnavaliable
    }
    
    public enum DeviceReason {
        case disconnected
        case noServices
        case noCharacteristics
        case failToConnect
        case failToDisconnect
    }
    
    public enum TaskReason {
        case sendFailed
        case paramsError
        case dataError
        case timeout
        case repeatTask
        case cancel
    }
    
    case phoneError(reason: PhoneReason)
    case deviceError(reason: DeviceReason)
    case taskError(reason: TaskReason)
}
