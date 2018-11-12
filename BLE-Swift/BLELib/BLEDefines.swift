//
//  Defines.swift
//  BLE-Swift
//
//  Copyright © 2018年 ss. All rights reserved.
//

import Foundation

// MARK: - 常量定义
public let kDefaultTimeout:TimeInterval = 10
public let kConnectTimeout:TimeInterval = 10
public let kScanTimeout:TimeInterval = 10


// MARK: - 闭包定义
public typealias GetReadyBlock = (NSError?)->Void
public typealias WriteBlock = (NSError?)->Void
public typealias ScanBlock = (Array<BLEDevice>?, NSError?)->Void
public typealias ConnectBlock = (BLEDevice?, NSError?)->Void
public typealias EmptyBlock = ()->Void
public typealias CommonCallback = (Any?, NSError?)->Void
public typealias BoolCallback = (Bool, NSError?)->Void
public typealias StringCallback = (String?, NSError?)->Void
public typealias IntCallback = (Int, NSError?)->Void


// MARK: - 错误码定义
public struct Code {
    static let bleUnavaiable = 9
    static let blePowerOff = 10
    static let deviceDisconnected = 13
    static let noServices = 11
    static let noCharacteristics = 12
    static let sendFailed = 15
    static let timeout = 20
    static let repeatOperation = 30
    static let paramsError = 40
    static let dataError = 50
}

public struct Domain {
    static let device = "BLEDevice"
    static let center = "BLECenter"
    static let data = "BLEData"
}

/// 键值对的健
public struct BLEKey {
    static let state = "BLEKey.state"
    static let device = "BLEKey.device"
    static let connectTask = "BLEKey.connectTask"
    static let task = "BLEKey.task"
}

// MARK: - 服务特征ID
public struct UUID {
    static let mainService = "6006"
    static let c8001 = "8001"
    static let c8002 = "8002"
    static let c8003 = "8003"
    static let c8004 = "8004"
}

// MARK: - 常量定义
/// 通知的常量
public struct BLENotification {
    
    /// 发送通知 userInfo 带 [BLEKey.state : CBManagerState]
    static let stateChanged = NSNotification.Name(rawValue: "BLENotification.stateChanged")
    static let deviceConnected = NSNotification.Name(rawValue: "BLENotification.deviceConnected")
    static let deviceDisconnected = NSNotification.Name(rawValue: "BLENotification.deviceDisconnected")
}

struct BLEInnerNotification {
    
    /// userInfo: BLEKey.device : Device
    static let deviceConnected = NSNotification.Name("BLECenterNotification.deviceConnected")
    
    /// userInfo: BLEKey.connectTask : ConnectTask
    static let deviceReady = NSNotification.Name("BLECenterNotification.deviceReady")
    
    /// userInfo: BLEKey.device : CBPeripheral
    static let deviceDisonnected = NSNotification.Name("BLECenterNotification.deviceDisconnected")
    
    /// userInfo: BLEKey.task : BLETask
    static let taskFinish = NSNotification.Name("BLECenterNotification.taskFinish")
}
