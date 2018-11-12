//
//  BLEDevicesManager.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/9.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEDevicesManager: NSObject {

    public static let shared = BLEDevicesManager()
    
    var connectLock = NSLock()
    var connectTaskList:Set<BLEConnectTask> = []
    var connectedDevices:Set<BLEDevice> = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        connectLock.name = "BLEDevicesManager.connectLock"
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceConnectedNotification(notification:)), name: BLEInnerNotification.deviceConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDisconnectedNotification(notification:)), name: BLEInnerNotification.deviceDisonnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceReadyNotification(notification:)), name: BLEInnerNotification.deviceReady, object: nil)
    }
    
    // MARK: - 通知处理
    @objc func deviceConnectedNotification(notification:Notification) {
        
    }
    
    @objc func deviceDisconnectedNotification(notification:Notification) {
        let peripheral = notification.userInfo![BLEKey.device] as! CBPeripheral
        guard let device = getConnectedDevice(byName: peripheral.name ?? "") else {
            return
        }
//        connectedDevices.remove(device)
        device.state = .disconnected
        NotificationCenter.default.post(name: BLENotification.deviceDisconnected, object: nil, userInfo: [BLEKey.device : device])
    }
    
    @objc func deviceReadyNotification(notification:Notification) {
        if let task = notification.userInfo?[BLEKey.connectTask] as? BLEConnectTask {
            if task.state == .success {
                self.connectedDevices.insert(task.device!)
            }
            DispatchQueue.main.async {
                // 回调连接的block
                task.connectBlock?(task.device, task.error)
                
                if task.device != nil && task.error == nil {
                    // 发送已经连接上的通知
                    NotificationCenter.default.post(name: BLENotification.deviceConnected, object: nil, userInfo: [BLEKey.device : task.device!])
                }
            }
            self.removeConnectTask(task: task)
        }
    }
    
    
    func connectDevice(withName name:String,
                       callback:ConnectBlock?,
                       timeout:TimeInterval = kDefaultTimeout) -> Bool {
        return acceptConnectTask(deviceName: name, callback: callback, timeout: timeout)
    }
    
    func connectDevice(withBLEDevice device:BLEDevice,
                       callback:ConnectBlock?,
                       timeout:TimeInterval = kDefaultTimeout) -> Bool {
        return acceptConnectTask(deviceName: device.name, callback: callback, timeout: timeout)
    }
    
    private func acceptConnectTask(deviceName name:String,
                                   callback:ConnectBlock?,
                                   timeout:TimeInterval = kDefaultTimeout) -> Bool {
        let task = BLEConnectTask(deviceName: name, connectBlock: callback, timeout: timeout)
        if addConnectTask(task: task) {
            task.start()
            return true
        } else {
            DispatchQueue.main.async {
                callback?(nil, NSError(domain: Domain.device, code: Code.repeatOperation, userInfo: nil))
            }
            return false
        }
    }
    // 由外部(BLECenter)通知设备连接上了
    func peripheralConnected(_ peripheral:CBPeripheral) {
        guard let task = getConnectTask(byName: peripheral.name ?? "") else {
            return
        }
        if task.device == nil {
            task.device = BLEDevice(peripheral)
        }
        task.device!.state = .connected
        // 扫描服务，特征值
        task.device!.scanServices { (err) in

            if err != nil {
                task.error = err
                task.device = nil
                task.state = .failed
            } else {
                task.error = nil
                task.state = .success
                task.device!.state = .ready
            }
            
            NotificationCenter.default.post(name: BLEInnerNotification.deviceReady, object: nil, userInfo: [BLEKey.connectTask : task])
        }
    }
    
//    func getAllConnectedDevices() -> Array<BLEDevice> {
//        return Array()
//    }
    
    func getConnectedDevice(byName name:String) -> BLEDevice? {
        for d in connectedDevices {
            if d.name == name {
                return d
            }
        }
        return nil
    }
    
    // MARK: - 链接设备工具方法
    func addConnectTask(task:BLEConnectTask) -> Bool {
        connectLock.lock()
        let flag = connectTaskList.insert(task).inserted
        connectLock.unlock()
        return flag
    }
    
    func removeConnectTask(task:BLEConnectTask) {
        connectLock.lock()
        task.ob = nil
        connectTaskList.remove(task)
        connectLock.unlock()
    }
    
    func getConnectTask(byName name:String) -> BLEConnectTask? {
        for task in connectTaskList {
            if task.name == name {
                return task
            }
        }
        return nil
    }
    
    func removeAllConnectTask() {
        connectLock.lock()
        connectTaskList.removeAll()
        connectLock.unlock()
    }
}
