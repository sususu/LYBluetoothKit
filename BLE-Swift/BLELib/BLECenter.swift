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
    
    public var state:CBManagerState = .unknown
    
    public var discoveredDevices:Set<BLEDevice> = Set()
    
    public var connectedDevices:[BLEDevice] {
        return Array(BLEDevicesManager.shared.connectedDevices)
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
    var searchTimer:Timer?
    var connectTimer:Timer?
    var otaConnectTimer:Timer?
    var disconnectTimer:Timer?
    
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
    public func scan(callback:ScanBlock?) {
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
                        discoveredDevices.insert(d)
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
        scan(callback: callback)
        self.block.scanStop = stop
        addSearchTimer(sel: #selector(stopScan), timeout: after)
    }
    
    private func scanCallback() {
        var devices = Array(self.discoveredDevices)
        // 按照信号量排序
        devices.sort { (d1, d2) -> Bool in
            let d1Rssi = d1.rssi ?? 0
            let d2Rssi = d2.rssi ?? 0
            return d1Rssi > d2Rssi
        }
        DispatchQueue.main.async {
            self.block.scanBlock?(devices, nil)
        }
    }
    
    /// Stop scanning bluetooth peripherals
    @objc public func stopScan() {
        removeSearchTimer()
        if self.state == .poweredOn {
            self.center?.stopScan()
        }
        self.block.scanStop?()
        self.block.scanBlock = nil
        self.block.scanStop = nil
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
            scan(callback: { (devices, err) in
                if devices != nil && devices!.count > 0 {
                    for device in devices! {
                        // 名字相同则进行连接
                        if deviceName == device.name {
                            weakSelf?.stopScan()
                            weakSelf?.center?.connect(device.peripheral, options: nil)
                        }
                    }
                }
            }, stop: {
                
            }, after: timeout)
        }
    }
    
    public func connect(device:BLEDevice, callback:ConnectBlock?,
        timeout:TimeInterval = kDefaultTimeout) {
        if devicesManager.connectDevice(withBLEDevice: device, callback: callback, timeout: timeout) {
            center?.connect(device.peripheral, options: nil)
        } else {
            callback?(device, BLEError.taskError(reason: .repeatTask))
        }
    }
    
    public func disconnect(device:BLEDevice, callback:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        if devicesManager.disconnectDevice(withBLEDevice: device, callback: callback, timeout: timeout) {
            center?.cancelPeripheralConnection(device.peripheral)
        } else {
            callback?(device, BLEError.taskError(reason: .repeatTask))
        }
    }
    
    
    func send(data:BLEData, callback:CommonCallback?, toDeviceName:String? = nil, timeout:TimeInterval = kDefaultTimeout) -> BLETask? {
        var deviceName = defaultInteractionDeviceName
        if toDeviceName != nil {
            deviceName = toDeviceName
        }
        
        if deviceName == nil {
            print("deviceName and defaultInteractionDeviceName can not be nil at the same time")
            DispatchQueue.main.async {
                callback?(nil, BLEError.taskError(reason: .paramsError))
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
        print("name:\(peripheral.name ?? "nil"), rssi:\(RSSI)")
        let device = BLEDevice(peripheral, rssi: RSSI, advertisementData: advertisementData)
        discoveredDevices.insert(device)
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
        if error != nil && peripheral.state == .connected {
            self.devicesManager.didFailToDisconnectPeripheral(peripheral)
        } else {
            self.devicesManager.didDisconnectPeripheral(peripheral)
        }
        
    }
    
    // MARK: - 超时处理
    private func removeSearchTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
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
}
