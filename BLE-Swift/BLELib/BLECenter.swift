//
//  BLECenter.swift
//  BLE-Swift
//
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit
import CoreBluetooth

public struct CenterBlock {
    var scanBlock:ScanBlock?
    var scanStop:EmptyBlock?
}

public class BLECenter: NSObject, CBCentralManagerDelegate {
    // MARK: - 公开属性
    /// shared instance
    public static let shared = BLECenter()
    
    public var state: CBManagerState = .unknown
    
    public var discoveredDevices: [BLEDevice] = []
    
    public var connectedDevices: [BLEDevice] {
        return BLEDevicesManager.shared.connectedDevices
    }
    
    public var hasConnectedDevice: Bool {
        return connectedDevices.count > 0
    }
    
    // MARK: - 私有属性
    var center:CBCentralManager?
    
    var devicesManager = BLEDevicesManager.shared
    
    var dataCenter = BLEDataCenter()
    
    // 蓝牙打开之后，需要做的任务列表
    var powerOnToDoList: Array<BLEToDo> = Array()
    var todoLock:NSLock = NSLock()
    
    // 回调
    var block:CenterBlock = CenterBlock()
    
    // 默认发送数据的设备名称
    var defaultInteractionDeviceName:String? {
        get {
            if connectedDevices.count > 0 {
                return connectedDevices[0].name
            }
            return nil
        }
    }
    
    // 定时器
    private var searchTimer:Timer?
    private var scanTaskTimer:Timer?
    private var connectTimer:Timer?
    private var otaConnectTimer:Timer?
    private var disconnectTimer:Timer?
    
    // 扫描任务列表
    private var scanTasks = [BLEScanTask]()
    
    // MARK: - 初始化
    override init() {
        super.init()
        
        self.todoLock.name = "BLECenter.todoLock"
        
        // 初始化center
        let options:[String : Any] = [CBCentralManagerOptionShowPowerAlertKey: true,
                       CBCentralManagerOptionRestoreIdentifierKey: "Appscomm.ble.center"]
        
        let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? Array<String>
        if let arr = backgroundModes, arr.contains("bluetooth-central") {
            center = CBCentralManager(delegate: self, queue: nil, options: options)
        } else {
            center = CBCentralManager(delegate: self, queue: nil)
        }
        
    }
    
    
    // MARK: - 公开方法
    
    /// Scan bluetooth peripherals.
    ///
    /// - Parameter callback: callback will be called once peripherals are found
    private func scan(callback:ScanBlock?) {
        if self.state == .unknown {
            addToDo(cmd: ToDo.scan) {
                [unowned self] in
                self.scan(callback: callback)
            }
        }
        else {
            if let err = checkBLE() {
                DispatchQueue.main.async {
                    callback?(nil, err)
                    self.stopScan()
                }
            } else {
                center?.stopScan()
                discoveredDevices.removeAll()
                block.scanBlock = callback
                let arr = getConnectedDevices(servicesUUIDs: [UUID.mainService])
                if arr != nil && arr!.count > 0 {
                    for d in arr! {
                        discoveredDevices.append(d)
                    }
                }
                
                scanCallback()
                
                center?.scanForPeripherals(withServices: nil, options: nil)
            }
        }
        
        
    }
    
    /// Scan bluetooth peripherals and stop scanning after a specified time ‘after’, then stop will be called.
    /// callback will be called once peripherals are found
    ///
    /// - Parameters:
    ///   - callback: peripherals found callback
    ///   - stop: stop callback
    ///   - after: seconds of stop count timer
    public func scan(callback:ScanBlock?,
                     stop:EmptyBlock?,
                     after:TimeInterval = kDefaultTimeout) {
        // 移除掉超时的
        removeTimeoutScanTask()
        
        // 如果当前有连接的扫描任务存在，那这个连接的扫描任务，是最优先的
        if scanTasks.count > 0 {
//            var devices = Array(self.discoveredDevices)
            // 按照信号量排序，不应该这里排序
//            devices.sort { (d1, d2) -> Bool in
//                let d1Rssi = d1.rssi ?? 0
//                let d2Rssi = d2.rssi ?? 0
//                return d1Rssi > d2Rssi
//            }
            DispatchQueue.main.async {
                self.block.scanBlock?(self.discoveredDevices, nil)
                stop?()
            }
            return
        }
        
        scan(callback: callback)
        self.block.scanStop = stop
        addSearchTimer(sel: #selector(stopScan), timeout: after)
    }
    
    private func beginConnectScan(task: BLEScanTask, after: TimeInterval = kDefaultTimeout) {
        // 先停掉其他扫描任务
//        scanCallback()
//        stopScan()
        
        scanTasks.append(task)
//        discoveredDevices.removeAll()
//        let arr = getConnectedDevices(servicesUUIDs: [UUID.mainService])
//        if arr != nil && arr!.count > 0 {
//            for d in arr! {
//                discoveredDevices.append(d)
//            }
//        }
//        scanCallback()
//        center?.scanForPeripherals(withServices: nil, options: nil)
        addScanTaskTimer(taskID: task.taskID, sel: #selector(stopScanTask(timer:)))
        
        beginLoopScan(interval: 10)
    }
    
    // 循环扫描
    private var lastScanTime: TimeInterval = 0
    private func beginLoopScan(interval: TimeInterval) {
        if scanTasks.count == 0 {
            return
        }
        
        if self.state != .poweredOn {
            return
        }
        
        let now = Date().timeIntervalSince1970
        if now - lastScanTime > interval {
            discoveredDevices.removeAll()
            center?.stopScan()
            
            let arr = getConnectedDevices(servicesUUIDs: [UUID.mainService])
            if arr != nil && arr!.count > 0 {
                for d in arr! {
                    discoveredDevices.append(d)
                }
            }
            scanCallback()
            
            center?.scanForPeripherals(withServices: nil, options: nil)
            lastScanTime = now
        }
        // 3秒钟重复一次
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.beginLoopScan(interval: interval)
        }
    }
    
    
    private func removeScanTask(byTaskID: String) {
        for i in 0 ..< scanTasks.count {
            let task = scanTasks[i]
            if task.taskID == byTaskID {
                scanTasks.remove(at: i)
                return
            }
        }
    }
    
    private func removeTimeoutScanTask() {
        let now = Date().timeIntervalSince1970
        
        scanTasks = scanTasks.filter { (task) -> Bool in
            return (now - task.startTimeInterval < task.timeout)
        }
    }
    
    
    private func scanCallback() {
//        var devices = Array(self.discoveredDevices)
//        // 按照信号量排序
//        devices.sort { (d1, d2) -> Bool in
//            let d1Rssi = d1.rssi ?? 0
//            let d2Rssi = d2.rssi ?? 0
//            return d1Rssi > d2Rssi
//        }
        DispatchQueue.main.async {
            self.block.scanBlock?(self.discoveredDevices, nil)
            
            // 连接扫描任务里面的，都要回调一次
            for task in self.scanTasks {
                task.scanCallback?(self.discoveredDevices, nil)
            }
        }
    }
    
    /// Stop scanning bluetooth peripherals
    @objc func stopScan() {
        removeSearchTimer()
        if self.state == .poweredOn {
            self.center?.stopScan()
        }
        self.block.scanStop?()
        self.block.scanBlock = nil
        self.block.scanStop = nil
    }
    
    @objc func stopScanTask(timer: Timer) {
        if self.state == .poweredOn && scanTasks.count == 0 {
            self.center?.stopScan()
        }
        guard let dict = timer.userInfo as? Dictionary<String, Any> else {
            removeScanTaskTimer()
            return
        }
        let taskID = dict["taskID"] as! String
        removeScanTask(byTaskID: taskID)
        removeScanTaskTimer()
    }
    
    
    /// connect device by name, default timeout is kConnectTimeout
    ///
    /// - Parameter deviceName: device's name(peripheral.name)
    public func connect(deviceName:String,
                        callback:ConnectBlock?,
                        timeout:TimeInterval = kDefaultTimeout) {
        if devicesManager.connectDevice(withName: deviceName, callback: callback, timeout: timeout) {
            // 先扫描，再连接
            weak var weakSelf = self
            let scanTask = BLEScanTask(taskID: deviceName, scanCallback: { (devices, err) in
                if devices != nil && devices!.count > 0 {
                    for device in devices! {
                        // 名字相同则进行连接
                        if deviceName == device.name {
//                            weakSelf?.stopScan()
                            weakSelf?.removeScanTask(byTaskID: deviceName)
                            weakSelf?.center?.connect(device.peripheral, options: nil)
                        }
                    }
                }
            }, stopCallback: nil)
            scanTask.timeout = timeout
            beginConnectScan(task: scanTask, after: timeout)
        } else {
            DispatchQueue.main.async {
                callback?(nil, BLEError.taskError(reason: .repeatTask))
            }
        }
    }
    
    public func connect(device:BLEDevice, callback:ConnectBlock?,
        timeout:TimeInterval = kDefaultTimeout) {
        if devicesManager.connectDevice(withBLEDevice: device, callback: callback, timeout: timeout) {
            center?.connect(device.peripheral, options: nil)
        }
        // 由添加任务里面操作，去处理没有添加任务成功的回调
//        else {
//            callback?(device, BLEError.taskError(reason: .repeatTask))
//        }
    }
    
    public func disconnect(device:BLEDevice, callback:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        if devicesManager.disconnectDevice(withBLEDevice: device, callback: callback, timeout: timeout) {
            center?.cancelPeripheralConnection(device.peripheral)
        } else {
            callback?(device, BLEError.taskError(reason: .repeatTask))
        }
    }
    
    public func disconnectAllConnectedDevices() {
        for device in self.connectedDevices {
            self.disconnect(device: device, callback: nil)
        }
    }
    
    
    func send(data:BLEData, callback:CommonCallback?, toDeviceName:String? = nil, timeout:TimeInterval = kDefaultTimeout) -> BLETask? {
        
        if state != .poweredOn {
            DispatchQueue.main.async {
                if self.state == .poweredOff {
                    callback?(nil, BLEError.phoneError(reason: .bluetoothPowerOff))
                } else {
                    callback?(nil, BLEError.phoneError(reason: .bluetoothUnavaliable))
                }
            }
            return nil
        }
        
        
        var deviceName = defaultInteractionDeviceName
        if toDeviceName != nil {
            deviceName = toDeviceName
        }
        
        if deviceName == nil || self.connectedDevices.count == 0 {
            print("deviceName and defaultInteractionDeviceName can not be nil at the same time")
            DispatchQueue.main.async {
                callback?(nil, BLEError.deviceError(reason: .disconnected))
            }
            return nil
        }
  
        
        if let device = devicesManager.getConnectedDevice(byName: deviceName!) {
            return dataCenter.sendData(toDevice: device, data: data, callback: callback)
        } else {
            print("Please connect a device before sending data")
            DispatchQueue.main.async {
                callback?(nil, BLEError.deviceError(reason: .disconnected))
            }
            return nil
        }
        
    }
    
    // MARK: - 蓝牙状态改变方法实现
    private func blePowerOn() {
        print("蓝牙打开了")
        // 检查需要打开蓝牙之后执行的任务
        let todoList = getAllTodos()
        for todo in todoList {
            todo.block()
        }
        removeAllTodo()
    }
    
    // MARK: - 蓝牙中心代理
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 先给自己属性赋值
        self.state = center!.state
        
        if self.state == .poweredOn {
            blePowerOn()
        }
        
        // 发送状态改变通知
        NotificationCenter.default.post(name: BLENotification.stateChanged, object: nil, userInfo: [BLEKey.state : self.state])
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("name:\(peripheral.name ?? "nil"), rssi:\(RSSI)")
        let device = BLEDevice(peripheral, rssi: RSSI, advertisementData: advertisementData)
        if !discoveredDevices.contains(device) {
            discoveredDevices.append(device)
        }
        
        DispatchQueue.main.async {
            self.scanCallback()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.devicesManager.peripheralConnected(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.devicesManager.peripheralFailToConnect(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // 如果有错误，并且，当前外设还是处于链接状态，则认为是断链失败了
        print("didDisconnectPeripheral:\(peripheral.name)")
        if error != nil && peripheral.state == .connected {
            print("still connected????? or error")
            self.devicesManager.didFailToDisconnectPeripheral(peripheral)
        } else {
            print("normal disconnect")
            self.devicesManager.didDisconnectPeripheral(peripheral)
        }
        
    }
    
    // MARK: - 超时处理
    private func removeSearchTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    private func removeScanTaskTimer() {
        scanTaskTimer?.invalidate()
        scanTaskTimer = nil
    }
    
    private func removeConnectTimer() {
        connectTimer?.invalidate()
        connectTimer = nil
    }
    
    private func removeOtaConnectTimer() {
        otaConnectTimer?.invalidate()
        otaConnectTimer = nil
    }
    
    private func removeDisconnectTimer() {
        disconnectTimer?.invalidate()
        disconnectTimer = nil
    }
    
    private func addSearchTimer(sel:Selector, timeout:TimeInterval = kDefaultTimeout) {
        removeSearchTimer()
        searchTimer = Timer(timeInterval: timeout, target: self, selector: sel, userInfo: nil, repeats: false)
        searchTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(self.searchTimer!, forMode: .common)
    }
    
    private func addScanTaskTimer(taskID: String, sel:Selector, timeout: TimeInterval = kDefaultTimeout) {
        removeScanTaskTimer()
        scanTaskTimer = Timer(timeInterval: timeout, target: self, selector: sel, userInfo: ["taskID": taskID], repeats: false)
        scanTaskTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(self.scanTaskTimer!, forMode: .common)
    }
    
    private func addDisconnectTimer(timeout:TimeInterval = kDefaultTimeout) {
        removeDisconnectTimer()
        disconnectTimer = Timer(timeInterval: timeout, target: self, selector: #selector(timeoutCallback(timer:)), userInfo: ["todo": ToDo.disconnect], repeats: false)
        disconnectTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(self.disconnectTimer!, forMode: .common)
    }
    
    private func addConnectTimer(isAutoConnect:Bool, timeout:TimeInterval = kDefaultTimeout) {
        removeConnectTimer()
        let todo = isAutoConnect ? ToDo.autoConnect : ToDo.connect
        connectTimer = Timer(timeInterval: timeout, target: self, selector: #selector(timeoutCallback(timer:)), userInfo: ["todo": todo], repeats: false)
        connectTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(self.connectTimer!, forMode: .common)
    }
    
    private func addOtaConnectTimer(timeout:TimeInterval = kDefaultTimeout) {
        removeOtaConnectTimer()
        otaConnectTimer = Timer(timeInterval: timeout, target: self, selector: #selector(timeoutCallback(timer:)), userInfo: ["todo": ToDo.otaConnect], repeats: false)
        otaConnectTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(self.otaConnectTimer!, forMode: .common)
    }
    
    @objc private func timeoutCallback(timer:Timer) {
        guard let userInfo = timer.userInfo as? Dictionary<String, Int> else {
            return
        }
        let todo = userInfo["todo"];
        switch todo {
        case ToDo.connect:
            if self.state == .poweredOn {
                self.center?.stopScan()
            }
            //if let callback = self.block.co
            print("do callback")
        
        default:
            print("not handled")
        }
    }
    
    // MARK: - 工具方法
    private func checkBLE() -> BLEError? {
        if self.state == .poweredOff {
            return BLEError.phoneError(reason: .bluetoothPowerOff)
        }
        else if self.state == .poweredOn {
            return nil
        }
        else {
            return BLEError.phoneError(reason: .bluetoothUnavaliable)
        }
    }
    
    private func getConnectedDevices(servicesUUIDs:Array<String>) -> Array<BLEDevice>? {
        
        var uuids:[CBUUID] = []
        for id in servicesUUIDs {
            uuids.append(CBUUID(string: id))
        }
        
        let arr = self.center?.retrieveConnectedPeripherals(withServices: uuids)
        guard let tmpArr = arr, tmpArr.count > 0 else {
            return nil
        }
        
        var devices:[BLEDevice] = []
        for peripheral in tmpArr {
            let device = BLEDevice(peripheral)
            devices.append(device)
        }
        return devices
    }
    
    private func addToDo(cmd:Int, block:@escaping EmptyBlock) {
        let todo = BLEToDo(cmd: cmd, block: block)
        todoLock.lock()
        powerOnToDoList.append(todo)
        todoLock.unlock()
    }
    
    private func removeTodo(byCmd:Int) {
        todoLock.lock()
        powerOnToDoList = powerOnToDoList.filter { (todo) -> Bool in
            return todo.cmd != byCmd
        }
        todoLock.unlock()
    }
    
    private func removeAllTodo() {
        todoLock.lock()
        powerOnToDoList.removeAll()
        todoLock.unlock()
    }
    
    private func getAllTodos() -> Array<BLEToDo> {
        return Array(powerOnToDoList)
    }
    
    public func isDeviceConnected(name: String?) -> Bool {
        if name == nil {
            return false
        }
        
        for d in self.connectedDevices {
            if d.name == name {
                return true
            }
        }
        return false
    }
    
    public func getConnectedDevice(withName name: String) -> BLEDevice? {
        for d in self.connectedDevices {
            if d.name == name {
                return d
            }
        }
        return nil
    }
    
}
