//
//  BLETask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/9.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

public enum BLETaskState {
    case plain
    case start
    case cancel
    case failed
    case success
}

@objcMembers public class BLETask: NSObject {
    var timer:Timer?
    var state:BLETaskState = .plain
    var error:NSError?
    var timeout:TimeInterval = kDefaultTimeout
    var ob:NSKeyValueObservation?
    
    func start() {
        startTimer()
    }
    
    func cancel() {
        
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer(timeInterval: timeout, target: self, selector: #selector(timeoutHandler), userInfo: nil, repeats: false)
        timer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil;
    }
    
    @objc func timeoutHandler() {
        
    }
}

@objcMembers public class BLEConnectTask: BLETask {
    var deviceName:String?
    var device:BLEDevice?
    var connectBlock:ConnectBlock?
    var isDisconnect = false
    
    var name:String? {
        return self.device?.name ?? self.deviceName;
    }
    
    deinit {
        connectBlock = nil
        ob = nil
    }
    
    init(deviceName:String, connectBlock:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        super.init()
        self.deviceName = deviceName
        self.timeout = timeout
        self.connectBlock = connectBlock
    }
    
    init(device:BLEDevice, connectBlock:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        super.init()
        self.device = device
        self.timeout = timeout
        self.connectBlock = connectBlock
    }
    
    override func timeoutHandler() {
        super.timeoutHandler()
        self.error = NSError(domain: Domain.device, code: Code.timeout, userInfo: nil)
        self.device = nil
        self.state = .failed
    }
    
    override public var hash: Int {
        return self.name?.hash ?? 0
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BLEConnectTask else {
            return false
        }
        return self.name == other.name
    }
}


// MARK: - Data Task
@objcMembers public class BLEDataTask: BLETask, BLEDataParserProtocol {
    var device:BLEDevice?
    var data:BLEData
    var callback:CommonCallback?
    
    var parser:BLEDataParser!
    
//    var name:String? {
//        return self.device?.name ?? self.deviceName;
//    }
    private var stateOb : NSKeyValueObservation?
    
    deinit {
        stateOb = nil
        callback = nil
        ob = nil
    }
    
    init(data:BLEData) {
        self.data = data
        super.init()
    }
    
    init(device:BLEDevice, data:BLEData, callback:CommonCallback?, timeout:TimeInterval = kDefaultTimeout) {
        self.data = data
        self.device = device
        self.callback = callback
        super.init()
        self.timeout = timeout
        
        self.parser = BLEDataParser()
        self.parser.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataUpdate), name: BLEInnerNotification.deviceDataUpdate, object: nil)
        
        // 监听
        weak var weakSelf = self
        stateOb = data.observe(\BLEData.stateRaw) { (bleData, change) in
//            print("hello")
            switch bleData.state {
            case .sendFailed:
                let error = NSError(domain: Domain.data, code: Code.sendFailed, userInfo: nil)
                weakSelf?.error = error
                weakSelf?.state = .failed
                weakSelf?.device = nil
                weakSelf?.parser.clear()
            case .recvFailed:
                let error = NSError(domain: Domain.data, code: Code.dataError, userInfo: nil)
                weakSelf?.error = error
                weakSelf?.state = .failed
                weakSelf?.device = nil
                weakSelf?.parser.clear()
            default:
                break
            }
            weakSelf?.stopTimer()
            if weakSelf != nil {
                NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : weakSelf!])
            }
        }
    }
    
    override func start() {
        super.start()
        parser.clear()
        
        if data.sendToUuid == nil {
            guard let uuid = BLEConfig.shared.sendUUID[data.type] else {
                data.error = NSError(domain: Domain.data, code: Code.noCharacteristics, userInfo: nil)
                data.state = .sendFailed
                return
            }
            data.sendToUuid = uuid
        }
        
        
        guard let sendDevice = device else {
            data.error = NSError(domain: Domain.data, code: Code.deviceDisconnected, userInfo: nil)
            data.state = .sendFailed
            return
        }
        
        if !sendDevice.write(data.sendData, characteristicUUID: data.sendToUuid!) {
            data.error = NSError(domain: Domain.data, code: Code.deviceDisconnected, userInfo: nil)
            data.state = .sendFailed
        }
    }
    
    @objc func deviceDataUpdate(notification: Notification) {
        guard let uuid = notification.userInfo?[BLEKey.uuid] as? String else {
            return
        }
        guard let data = notification.userInfo?[BLEKey.data] as? Data else {
            return
        }
        
        if uuid == self.data.sendToUuid {
            parser.standardParse(data: data, sendData: self.data.sendData, recvCount: self.data.recvDataCount)
        }
        
    }

    override func timeoutHandler() {
        super.timeoutHandler()
        self.error = NSError(domain: Domain.data, code: Code.timeout, userInfo: nil)
        self.device = nil
        self.state = .failed
        NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : self])
    }
    
    /// MARK: - 代理实现
    func didFinishParser(data: Data, dataArr: Array<Data>, recvCount: Int) {
        if self.data.recvDataCount == recvCount {
            self.data.recvDatas = dataArr
            self.data.recvData = data
            stopTimer()
        }
    }
    
}
