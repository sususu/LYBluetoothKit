//
//  BLEDevice.swift
//  BLE-Swift
//
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 设备的状态
///
/// - disconnected: 断连状态
/// - connected: 连接状态
/// - ready: 准备就绪状态（关键服务和特征找到了）
public enum BLEDeviceState {
    case disconnected
    case connected
    case ready
}


protocol BLEDeviceDelegate: NSObjectProtocol {
    func deviceDidUpdateData(data: Data, deviceName: String, uuid: String)
}

public class BLEDevice: NSObject, CBPeripheralDelegate {

    /// peripheral's state
    /// @see BLEDeviceState
    public var state:BLEDeviceState = .disconnected
    public var name:String = ""
    public var rssi:Int!
    
    /// all services of peripheral
    var services:Dictionary<String, CBService> = Dictionary()
    var discoveredServices:[CBService] = []
    /// service uuids in broadcast package
    var broadcastServiceUUIDs:[String] = []
    
    /// all characteristics of peripheral's services
    var characteristics:Dictionary<String, CBCharacteristic> = Dictionary()
    
    var peripheral:CBPeripheral
    
    var getReadyCallback:GetReadyBlock?
    
    weak var delegate: BLEDeviceDelegate?
    
    // MARK: - 初始化
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(_ peripheral:CBPeripheral) {
        self.peripheral = peripheral
        self.name = peripheral.name ?? ""
        self.rssi = 0;
        super.init()
        self.peripheral.delegate = self
    }
    
    public convenience init(_ peripheral:CBPeripheral, rssi:NSNumber, advertisementData:Dictionary<String, Any>) {
        self.init(peripheral)
        self.rssi = rssi.intValue
        if self.rssi > 0 {
            self.rssi = 0
        }
        if let name = advertisementData["kCBAdvDataLocalName"] as? String {
            self.name = name
        }
    }
    
    // MARK: - 公开方法
    public func scanServices(callback:GetReadyBlock?) {
        self.getReadyCallback = callback
        self.discoveredServices.removeAll()
        self.peripheral.discoverServices(nil)
        self.peripheral.delegate = self
    }
    
    public func write(_ data:Data, characteristicUUID:String) -> Bool {
        
//        print("发送数据（\(characteristicUUID)）：\(data.hexEncodedString())")
        
        if peripheral.state != .connected {
            return false
        }
        
        guard let characteristic = self.characteristics[characteristicUUID]  else {
            return false
        }
        
        doSliceWrite(data, characteristic: characteristic)
        return true
    }
    
    public func read(characteristicUUID:String) -> Bool {
        if peripheral.state != .connected {
            return false
        }
        
        guard let characteristic = self.characteristics[characteristicUUID]  else {
            return false
        }
        
        self.peripheral.readValue(for: characteristic)
        return true
    }
    
    
    /// 分包发送，按照mtu（单次发送数据包大小）分多次发送到手表，mtu默认大小是20
    ///
    /// - Parameters:
    ///   - data: 发送数据
    ///   - characteristic: 发送的特征
    private func doSliceWrite(_ data:Data, characteristic:CBCharacteristic)
    {
        var type = CBCharacteristicWriteType.withResponse;
        if characteristic.properties.contains(.writeWithoutResponse) {
            type = .withoutResponse;
        }
        
        let mtu = BLEConfig.shared.mtu;
        let lengthLeft = data.count % mtu;
        let lengthTimes = data.count / mtu;
        
        for i in 0..<lengthTimes {
            let subData = data.subdata(in: i * mtu ..< (i + 1) * mtu);
            self.peripheral.writeValue(subData, for: characteristic, type: type)
//            print("\(self.name)(\(characteristic.uuid.uuidString)) write: \(subData.hexEncodedString())")
        }
        
        if lengthLeft > 0 {
            let subData = data.subdata(in: lengthTimes * mtu ..< lengthTimes * mtu + lengthLeft)
            self.peripheral.writeValue(subData, for: characteristic, type: type)
//            print("\(self.name)(\(characteristic.uuid.uuidString)) write: \(subData.hexEncodedString())")
        }
        
    }
    
    // MARK: - 公开方法
    public func hasService(withUUID uuid: String) -> Bool {
        if let _ = services[uuid] {
            return true
        }
        return false
    }
    
    
    // MARK: - 代理实现
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.rssi = RSSI.intValue
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            self.getReadyCallback?(BLEError.deviceError(reason: .noServices))
        } else {
            if let services = peripheral.services {
                for service in services {
                    self.services[service.uuid.uuidString] = service;
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            } else {
                self.getReadyCallback?(BLEError.deviceError(reason: .noServices))
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            self.getReadyCallback?(BLEError.deviceError(reason: .noCharacteristics))
        } else {
            self.discoveredServices.append(service)
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    self.characteristics[characteristic.uuid.uuidString] = characteristic;
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
            if self.discoveredServices.count == (peripheral.services?.count ?? 0) {
                self.getReadyCallback?(nil)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let data = characteristic.value else {
            return
        }
        
        print("\(self.name)(\(characteristic.uuid.uuidString)) recv data:\(data.hexEncodedString()))")
        
        delegate?.deviceDidUpdateData(data: data, deviceName: self.name, uuid: characteristic.uuid.uuidString)
        
        NotificationCenter.default.post(name: BLEInnerNotification.deviceDataUpdate, object: nil, userInfo: [BLEKey.data : data, BLEKey.uuid : characteristic.uuid.uuidString, BLEKey.device: self])
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // 不处理事情
        
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//        print("peripheralIsReady")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("订阅 \(characteristic.uuid.uuidString) 成功")
    }
    
    // MARK: - 相等判断
    public override var hash: Int {
        return self.name.hashValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BLEDevice else {
            return false
        }
        return self.name == other.name
    }
    
    // MARK: - 调试打印
    public override var description: String {
        return "name:\(name), rssi:\(rssi ?? 0), state:\(state)"
    }
    
    public override var debugDescription: String {
        return "name:\(name), rssi:\(rssi ?? 0), state:\(state)"
    }
}
