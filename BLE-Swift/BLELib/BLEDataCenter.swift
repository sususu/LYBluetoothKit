//
//  BLEDataHandler.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/11.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

class BLEDataCenter: NSObject {
    
    var dataTaskList:[BLEDataTask] = []
    var responseTaskList:[BLEDataTask] = []
    var addressBookTaskList:[BLEDataTask] = []
    
    var currentDataTask:BLEDataTask?
    var currentResponseTask:BLEDataTask?
    var currentAddressTask:BLEDataTask?
    
    let taskCrudLock = NSLock()
    let taskExcutionQueue = DispatchQueue(label: "BLEDataCenter.taskExcutionQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        taskCrudLock.name = "BLEDataCenter.taskLock"
        NotificationCenter.default.addObserver(self, selector: #selector(taskFinishNotification(notification:)), name: BLEInnerNotification.taskFinish, object: nil)
    }

    func sendData(toDeviceName deviceName:String, data:BLEData, callback:CommonCallback?, timeout:TimeInterval = kDefaultTimeout) -> BLEDataTask {
        guard let device = BLEDevicesManager.shared.getConnectedDevice(byName: deviceName) else {
            let error = BLEError.deviceError(reason: .disconnected)
            callback?(nil, BLEError.deviceError(reason: .disconnected))
            data.error = error
            return BLEDataTask(data: data)
        }
        return sendData(toDevice: device, data: data, callback: callback, timeout: timeout)
    }
    
    func sendData(toDevice device:BLEDevice, data:BLEData, callback:CommonCallback?, timeout:TimeInterval = kDefaultTimeout) -> BLEDataTask {
        if device.state == .disconnected {
            let error = BLEError.deviceError(reason: .disconnected)
            callback?(nil, error)
            data.error = error
            return BLEDataTask(data: data)
        }
        
        let task = BLEDataTask(device: device, data: data, callback: callback, timeout: timeout)
        addTask(task: task)
        beginTask()
    
        return task
    }
    
    @objc func taskFinishNotification(notification:Notification) {
        
        guard let task = notification.userInfo![BLEKey.task] as? BLEDataTask else {
            return
        }
        DispatchQueue.main.async {
            task.callback?(task.data, task.data.error)
            task.callback = nil
        }
        self.removeTask(task: task)
    }
    
    // MARK: - 任务开始
    func beginTask() {
        weak var weakSelf = self
        // 开始普通数据任务
        if currentDataTask?.state == .plain {
            taskExcutionQueue.async {
                weakSelf?.currentDataTask?.start()
            }
        } else if (currentDataTask?.state != .start) {
    
            let task = self.getTask(type: .normal)
            
            if task != nil {
                self.currentDataTask = task;
                self.beginTask()
            }
        }
        
        // 开始响应任务
        if currentResponseTask?.state == .plain {
            taskExcutionQueue.async {
                weakSelf?.currentResponseTask?.start()
            }
        } else if (currentResponseTask?.state != .start) {
            
            let task = self.getTask(type: .response)
            
            if task != nil {
                self.currentResponseTask = task;
                self.beginTask()
            }
        }
        
        // 开启通讯录任务
        if currentAddressTask?.state == .plain {
            taskExcutionQueue.async {
                weakSelf?.currentAddressTask?.start()
            }
        } else if (currentAddressTask?.state != .start) {
            
            let task = self.getTask(type: .addressBook)
            
            if task != nil {
                self.currentAddressTask = task;
                self.removeTask(task: task!)
                self.beginTask()
            }
        }
        
    }
    
    
    // MARK: - 任务增删改
    func getTask(type:BLEDataType) -> BLEDataTask? {
        var task:BLEDataTask?
        taskCrudLock.lock()
        switch type {
        case .normal:
            task = self.dataTaskList.first
        case .response:
            task = self.responseTaskList.first
        case .addressBook:
            task = self.addressBookTaskList.first
        }
        taskCrudLock.unlock()
        return task
    }
    
    func getTaskCount(type:BLEDataType) -> Int {
        var count:Int = 0
        taskCrudLock.lock()
        switch type {
        case .normal:
            count = self.dataTaskList.count
        case .response:
            count = self.responseTaskList.count
        case .addressBook:
            count = self.addressBookTaskList.count
        }
        taskCrudLock.unlock()
        return count
    }
    
    
    func addTask(task:BLEDataTask) {
        taskCrudLock.lock()
        switch task.data.type {
        case .normal:
            self.dataTaskList.append(task)
        case .response:
            self.responseTaskList.append(task)
        case .addressBook:
            self.addressBookTaskList.append(task)
        }
        taskCrudLock.unlock()
    }
    
    func removeTask(task:BLEDataTask) {
        taskCrudLock.lock()
        switch task.data.type {
        case .normal:
            self.dataTaskList.remove(task)
        case .response:
            self.responseTaskList.remove(task)
        case .addressBook:
            self.addressBookTaskList.remove(task)
        }
        taskCrudLock.unlock()
    }
    
    func removeAllTask() {
        taskCrudLock.lock()
        let dataTasks = self.dataTaskList
        let responseTasks = self.responseTaskList
        let addressTasks = self.addressBookTaskList
        taskCrudLock.unlock()
        
        DispatchQueue.main.async {
            
            for task in dataTasks {
                task.callback?(nil, task.data.error)
            }
            
            for task in responseTasks {
                task.callback?(nil, task.data.error)
            }
            
            for task in addressTasks {
                task.callback?(nil, task.data.error)
            }
        }
        
        // 值类型直接删除
        taskCrudLock.lock()
        self.dataTaskList.removeAll()
        self.responseTaskList.removeAll()
        self.addressBookTaskList.removeAll()
        taskCrudLock.unlock()
    }
    
}
