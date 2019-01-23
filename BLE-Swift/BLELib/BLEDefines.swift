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
public typealias GetReadyBlock = (BLEError?)->Void
public typealias WriteBlock = (BLEError?)->Void
public typealias ScanBlock = (Array<BLEDevice>?, BLEError?)->Void
public typealias ConnectBlock = (BLEDevice?, BLEError?)->Void
public typealias EmptyBlock = ()->Void
public typealias CommonCallback = (Any?, BLEError?)->Void
public typealias BoolCallback = (Bool, BLEError?)->Void
public typealias DataArrayCallback = (Array<Data>?, BLEError?)->Void
public typealias StringCallback = (String?, BLEError?)->Void
public typealias IntCallback = (Int, BLEError?)->Void
public typealias DictArrayCallback = (Array<Dictionary<String, Any>>?, BLEError?)->Void
public typealias FloatCallback = (Float)->Void


// MARK: - 错误码定义
public struct Code {
    static let bleUnavaiable = 9
    static let blePowerOff = 10
    static let deviceDisconnected = 13
    static let noServices = 11
    static let failToConnect = 99
    static let failToDisconnect = 98
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
    static let data = "BLEKey.data"
    static let uuid = "BLEKey.uuid"
}

// MARK: - 服务特征ID
public struct UUID {
    static let mainService = "6006"
    static let c8001 = "8001"
    static let c8002 = "8002"
    static let c8003 = "8003"
    static let c8004 = "8004"
    
    static let otaService = "1530"
    static let otaNotifyC = "1531"
    static let otaWriteC = "1532"
    
    static let nordicDFUService = "00001530-1212-EFDE-1523-785FEABCD123"
    static let nordicOtaBat = "00001531-1212-EFDE-1523-785FEABCD123"
    static let nordicOtaBin = "00001532-1212-EFDE-1523-785FEABCD123"
    static let nordicVersion = "00001534-1212-EFDE-1523-785FEABCD123"
    
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
//    static let deviceDisonnected = NSNotification.Name("BLECenterNotification.deviceDisconnected")
    
    /// userInfo: BLEKey.task : BLETask
    static let taskFinish = NSNotification.Name("BLECenterNotification.taskFinish")
    
    /// userInfo: BLEKey.uuid : String;  BLEKey.data : Data;
    /// BLEKey.device: BLEDevice
    static let deviceDataUpdate = NSNotification.Name("BLECenterNotification.deviceDataUpdate")
    
    /// userInfo: BLEKey.data : Data
    static let c8004DataComes = NSNotification.Name("BLECenterNotification.c8004DataComes")
}
