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
    var connectedDevices:[BLEDevice] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        connectLock.name = "BLEDevicesManager.connectLock"
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - 通知处理
    func deviceConnectTimeout(withTask task: BLEConnectTask) {
        DispatchQueue.main.async {
            // 回调连接的block
            task.connectBlock?(task.device, task.error)
            self.removeConnectTask(task: task)
        }
    }
    
    @objc func applicationBecomeActive() {
        connectLock.lock()
        for task in connectTaskList {
            if task.isTimeout {
                task.connectFailed(err: BLEError.taskError(reason: .timeout))
            }
        }
        connectTaskList = connectTaskList.filter({ (task) -> Bool in
            return !task.isTimeout
        })
        connectLock.unlock()
    }
    
    func deviceConnected(withTask task: BLEConnectTask) {
        
    }
    
    func deviceReady(withTask task: BLEConnectTask) {
        if task.state == .success {
            if self.connectedDevices.contains(task.device!) {
                self.connectedDevices.remove(task.device!)
            }
            self.connectedDevices.insert(task.device!, at: 0)
        }
        DispatchQueue.main.async {
            // 回调连接的block
            self.removeConnectTask(task: task)
            task.connectBlock?(task.device, task.error)
            task.connectBlock = nil
            
            if task.device != nil && task.error == nil {
                // 发送已经连接上的通知
                NotificationCenter.default.post(name: BLENotification.deviceConnected, object: nil, userInfo: [BLEKey.device : task.device!])
            }
        }
    }
    
    func deviceDisconnected(withTask task: BLEConnectTask) {
        DispatchQueue.main.async {
            // 回调连接的block
            task.connectBlock?(task.device, task.error)
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
    
    func disconnectDevice(withBLEDevice device:BLEDevice, callback:ConnectBlock?, timeout: TimeInterval = kDefaultTimeout) -> Bool {
        return acceptConnectTask(deviceName: device.name, callback: callback, timeout: timeout, isDisconnect: true)
    }
    
    
    private func acceptConnectTask(deviceName name:String,
                                   callback:ConnectBlock?,
                                   timeout:TimeInterval = kDefaultTimeout,
                                   isDisconnect: Bool = false) -> Bool {
        let task = BLEConnectTask(deviceName: name, connectBlock: callback, timeout: timeout)
        task.isDisconnect = isDisconnect
        if addConnectTask(task: task) {
            task.start()
            return true
        } else {
            DispatchQueue.main.async {
                callback?(nil, BLEError.taskError(reason: .repeatTask))
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
        weak var weakSelf = self
        task.device!.scanServices { (err) in

            if err != nil {
                task.connectFailed(err: err!)
            } else {
                task.connectSuccess()
            }
            weakSelf?.deviceReady(withTask: task)
        }
    }
    
    func peripheralFailToConnect(_ peripheral:CBPeripheral) {
        guard let task = getConnectTask(byName: peripheral.name ?? "") else {
            return
        }
        if task.device == nil {
            task.device = BLEDevice(peripheral)
        }
        task.device!.state = .disconnected
        task.error = BLEError.deviceError(reason: .failToConnect)
        task.state = .failed
    }
    
    func didDisconnectPeripheral(_ peripheral:CBPeripheral) {
        
        guard let device = getConnectedDevice(byName: peripheral.name ?? "") else {
            return
        }
        // 从已链接的设备列表中移除
        connectedDevices.remove(device)
        // 设置状态为未链接
        device.state = .disconnected
        // 对外通知，设备已经断开链接
        NotificationCenter.default.post(name: BLENotification.deviceDisconnected, object: nil, userInfo: [BLEKey.device : device])
        
        // 处理任务回调
        guard let task = getConnectTask(byName: peripheral.name ?? "") else {
            return
        }
        if task.device == nil {
            task.device = device
        }
        task.connectSuccess()
        task.device!.state = .disconnected
        task.error = nil
        task.state = .success
        deviceDisconnected(withTask: task)
    }
    
    func didFailToDisconnectPeripheral(_ peripheral:CBPeripheral) {
        
        guard let task = getConnectTask(byName: peripheral.name ?? "") else {
            return
        }
        task.error = BLEError.deviceError(reason: .failToDisconnect)
        task.state = .failed
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
        // 如果是断开链接的任务，那之前加入相同名字的链接任务，都应该清除掉
        if task.isDisconnect {
            var repeatTasks = Array<BLEConnectTask>()
            for t in connectTaskList {
                if task.name == t.name && !t.isDisconnect {
                    repeatTasks.append(t)
                }
            }
            for t in repeatTasks {
                connectTaskList.remove(t)
            }
        }
        
        // 加入任务
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
