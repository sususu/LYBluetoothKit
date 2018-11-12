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

public class BLEDevice: NSObject, CBPeripheralDelegate {

    /// peripheral's state
    /// @see BLEDeviceState
    public var state:BLEDeviceState = .disconnected
    public var name:String = ""
    public var rssi:Int!
    
    /// all services of peripheral
    var services:Dictionary<String, CBService> = Dictionary()
    var discoveredServices:[CBService] = []
    
    /// all characteristics of peripheral's services
    var characteristics:Dictionary<String, CBCharacteristic> = Dictionary()
    
    var peripheral:CBPeripheral
    
    var getReadyCallback:GetReadyBlock?
    
    var sendData:BLEData?
    var responseData:BLEData?
    var addressBookData:BLEData?
    
    // MARK: - 初始化
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(_ peripheral:CBPeripheral) {
        self.peripheral = peripheral
        self.name = peripheral.name ?? ""
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
    
    public func write(_ data:Data, characteristicUUID:String) {
        if let characteristic = self.characteristics[characteristicUUID] {
            print("write data:\(String(describing: data.hexEncodedString())) to:\(characteristicUUID)")
            if characteristic.properties.contains(.writeWithoutResponse) {
                
                self.peripheral.writeValue(data, for:characteristic, type:.withoutResponse)
            } else {
                
                self.peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        } else {
            print("can not find invalid characteristic to write data")
        }
    }
    // 发送数据
    func writeData(data:BLEData) {
        data.state = .sending
        
        let uuid = BLEConfig.shared.sendUUID[data.type]
        if uuid != nil && peripheral.state == .connected {
            write(data.sendData, characteristicUUID: uuid!)
            if uuid == BLEConfig.shared.sendUUID[.normal] {
                write03End()
            }
        } else {
            data.state = .sendFailed
//            NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : self])
        }
        data.state = .sent
        
        switch data.type {
        case .normal:
            sendData = data
            
        case .response:
            responseData?.state = .recved
//            NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : self])
        case .addressBook:
            addressBookData = data
        }
        
    }
    
    func write03End() {
        write(Data([0x03]), characteristicUUID: BLEConfig.shared.recvUUID[BLEDataType.normal]!)
    }
    
    // MARK: - 代理实现
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.rssi = RSSI.intValue
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            self.getReadyCallback?(error as NSError?)
        } else {
            if let services = peripheral.services {
                for service in services {
                    self.services[service.uuid.uuidString] = service;
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            } else {
                let error = NSError(domain: Domain.device, code: Code.noServices, userInfo: nil)
                self.getReadyCallback?(error)
            }
        }
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            self.getReadyCallback?(error as NSError?)
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
        let sendDataUUID = BLEConfig.shared.recvUUID[.normal]
        let responseDataUUID = BLEConfig.shared.recvUUID[.response]
        let addressBookDataUUID = BLEConfig.shared.recvUUID[.addressBook]
        let heartRateUUID = BLEConfig.shared.heartRateUUID
        
        print("recv data:\(String(describing: characteristic.value?.hexEncodedString()))")
        
        switch characteristic.uuid.uuidString {
        case sendDataUUID:
            handleRecvData(data: characteristic.value)
            
        case heartRateUUID:
            handleHeartRateData(data: characteristic.value)
            
        case responseDataUUID:
            handleRequestData(data: characteristic.value)
            
        case addressBookDataUUID:
            handleAddressBookData(data: characteristic.value)
            
        default:
            handleUnknownData(data: characteristic.value)
        }

    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // 不处理事情
        
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("peripheralIsReady")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("订阅 \(characteristic.uuid.uuidString) 成功")
    }
    
    // MARK: - 数据处理
    
    // 设备响应数据
    func handleRecvData(data:Data?) {
        guard let sendM = sendData, let recvData = data else {
            return
        }
        let sendBytes = sendM.sendData.bytes
        let recvBytes = recvData.bytes
        
        // 目前只支持新协议
        // 如果开头是 0x6f，可能是开头，如果是 0x6f + 指令码 + 0x80 那就是开头了
        if recvBytes[0] == 0x6f && recvBytes.count > 2 {
            
            if recvBytes[1] == sendBytes[1] {
                // 模版：0x6f 0x02 0x80 0x00 0x00 0x8f
                // 具体含义，请查看appscomm蓝牙协议文档
                if (recvBytes[2] == 0x80 || recvBytes[2] == 0x81) && recvBytes.count >= 6 {
                    
                    // 查询指令，接下来两位是数据长度
                    sendM.recvDataLength = Int(recvBytes[3]) + Int(recvBytes[4] << 8)
                    
//                    if recvBytes.count - 6 >= sendM.recvDataLength {
//
//                        sendM.recvData = data?.subdata(in: 5..<sendM.recvDataLength + 5)
//                    } else {
//                        sendM.recvData = data?.subdata(in: 5..<data!.count)
//                    }
                    
                    sendM.recvData = data?.subdata(in: 5..<data!.count)
                    
                } else {
                    sendM.recvData?.append(data!)
                }
                
            } else {
                sendM.recvData?.append(data!)
            }
        }
        else
        {
            sendM.recvData?.append(data!)
        }
        
        // 判断是否结束
        // +1 是因为，最后带了一个0x8f
        if sendM.recvData!.count >= (sendM.recvDataLength + 1) {
            // 最起码是单条结束了，如果是多条，另外处理
            // 去掉最后一个 0x8f
            sendM.recvData = sendM.recvData!.subdata(in: 0..<sendM.recvData!.count - 1)
            if sendM.recvDataCount > 1 {
                if sendM.recvDatas == nil {
                    sendM.recvDatas = [sendM.recvData!]
                } else {
                    sendM.recvDatas?.append(sendM.recvData!)
                }
                sendM.recvData = nil
            }
            
            // 结束了
            if sendM.recvDataCount == 1 || sendM.recvDataCount == sendM.recvDatas!.count {
                sendM.state = .recved
//                NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : self])
            }
            
        }
        
        
    }
    // 设备请求数据
    func handleRequestData(data:Data?) {
        
    }
    // 处理通讯录数据
    func handleAddressBookData(data:Data?) {
        
    }
    // 标准心率数据
    func handleHeartRateData(data:Data?) {
        
    }
    // 处理未知数据
    func handleUnknownData(data:Data?) {
        
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
