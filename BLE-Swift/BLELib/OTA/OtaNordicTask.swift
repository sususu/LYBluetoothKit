//
//  OtaNordicTask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/23.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kOtaNordicTaskOneDataSize = 20
let kOtaNordicTaskResponseNum = 20

class OtaNordicTask: OtaTask {
    
    override func start() {
        if device.state == .disconnected {
            otaFailed(error: BLEError.deviceError(reason: .disconnected))
            return
        }
        
        if otaDatas.count == 0 {
            otaFailed(error: BLEError.taskError(reason: .paramsError))
            return
        }
        
        var tmpArr = [OtaDataModel]()
        for var dm in otaDatas
        {
            if !dm.getNordicDataReady() {
                let err = BLEError.taskError(reason: .paramsError)
                self.otaFailed(error: err)
                return
            }
            tmpArr.append(dm)
        }
        otaDatas = tmpArr
        enterUpgradeMode()
    }
    
    
    
    private func enterUpgradeMode() {
        var kl17Data = Data(bytes: [0, 0, 0, 0, 0])
        var hrData = Data(bytes: [0, 0, 0, 0, 0])
        var tpData = Data(bytes: [0, 0, 0, 0, 0])
        
        for dm in self.otaDatas {
            if dm.type == .heartRate {
                hrData = dm.data
            }
            else if dm.type == .touchPanel {
                tpData = dm.data
            }
            else if dm.type == .freeScale {
                kl17Data = dm.data
            }
        }
        // 因为现在已经没有kl17 这个玩意了
        let kl17Bytes = kl17Data.bytes
        let hrBytes = hrData.bytes
        let tpBytes = tpData.bytes
        
        let cmd: [UInt8] = [0x6f, 0x0e, 0x71, 16, 0x00, 0x00,
                   kl17Bytes[0], kl17Bytes[1], kl17Bytes[2], kl17Bytes[3], kl17Bytes[4],
                   tpBytes[0], tpBytes[1], tpBytes[2], tpBytes[3], tpBytes[4],
                   hrBytes[0], hrBytes[1], hrBytes[2], hrBytes[3], hrBytes[4], 0x8f]
        
        let data = Data(bytes: cmd)
        weak var weakSelf = self
        _ = BLECenter.shared.send(data: data, boolCallback: { (b, err) in
            if err != nil {
                self.otaFailed(error: err!)
                return
            }
            weakSelf?.connectOtaDevice()
        }, toDeviceName: device.name)
        
    }
    
    
    private func connectOtaDevice() {
        weak var weakSelf = self
        BLECenter.shared.connect(deviceName: otaBleName, callback: { (bd, err) in
            if err != nil {
                self.otaFailed(error: err!)
                return
            }
            weakSelf?.device = bd!
            weakSelf?.startOta()
        })
    }
    
    private func startOta() {

        otaReady()
        
        var length = 0
        for dm in otaDatas {
            length += dm.otaData.count
        }
        sendLength = 0
        totalLength = length
        
        
        addTimer(timeout: 10, action: 1)
        // 发送0x09
        // 设置OTA复位，每一次升级流程只发一次，
        // 09后的数据包 ，如果有字库升级，后4个字节直接使用字库bin前4字节
        // 前4个字节总长度要减去4个字节。
        
        let data = Data(bytes: [0x09])
        writeDatData(data)
        
        // 发送09之后，发送数据长度和字库地址
        var settingData = Data(bytes: &totalLength, count: 4)
        var picAdd = Data(bytes: [0x00, 0x00, 0x00, 0x00])
        for dm in otaDatas {
            if dm.type == .picture {
                picAdd = dm.otaAddressData
            }
        }
        settingData.append(picAdd)
        
        writeBinData(settingData)
    }
    
    private func sendTypeData() {
        addTimer(timeout: 10, action: 2)
        
        let dm = otaDatas[0]
        
        // 发送类型数据
        writeDatData(dm.typeData)
        
        var data = Data(bytes: [0x00, 0x00, 0x00, 0x00,
                                0x00, 0x00, 0x00, 0x00])
        var length = dm.otaData.count
        data.append(bytes: &length, count: 4)
        writeBinData(data)
    }
    
    private func sendInitData() {
        addTimer(timeout: 10, action: 2)
        
        let dm = otaDatas[0]
        
        // 初始化固件
        let initStart = Data(bytes: [0x02, 0x00])
        writeDatData(initStart)
        
        // 发送数据
        writeBinData(dm.crcData)
        
        // 初始化完成
        let initEnd = Data(bytes: [0x02, 0x01])
        writeDatData(initEnd)
    }
    
    private func sendOtaBinData() {
        addTimer(timeout: 5, action: 3)
        
        var data = Data(bytes: [0x08, UInt8(kOtaNordicTaskResponseNum), 0])
        writeDatData(data)
        
        // 可以传输文件
        data = Data(bytes: [0x03])
        writeDatData(data)
        
        sendPackages()
    }
    
    private func sendPackages() {
        addTimer(timeout: 15, action: 3)
        
        if otaDatas.count <= 0 ||
           otaDatas[0].sections.count < 0 {
            return
        }
        
        let packages = otaDatas[0].sections[0].packageList
        
        for i in 0 ..< packages.count {
            let data = packages[i]
            //            print("package(\(i))data: \(data.hexEncodedString())")
            writeBinData(data)
            sendLength += data.count
            
            otaProgressUpdate()
        }
    }
    
    private func sendFileEnd() {
        addTimer(timeout: 5, action: 4)
        let data = Data(bytes: [0x04])
        writeDatData(data)
    }
    
    private func sendOtaEnd() {
//        addTimer(timeout: 10, action: 5)
        let data = Data(bytes: [0x05])
        writeDatData(data)
        
        otaFinish()
    }
    
    private var line = 0
    // MARK: - 写数据
    func writeBinData(_ data: Data) {
        if checkIsCancel() {
            return
        }
        print("写数据BinData(\(line))：\(data.hexEncodedString())")
        _ = device.write(data, characteristicUUID: UUID.nordicOtaBin)
        line += 1;
    }
    
    func writeDatData(_ data: Data) {
        if checkIsCancel() {
            return
        }
        print("写数据DatData：\(data.hexEncodedString())")
        _ = device.write(data, characteristicUUID: UUID.nordicOtaBat)
        
    }
    
    // MARK: - 接收数据
    @objc override func deviceDataUpdate(notification: Notification?) {
        //nordicOtaBat
        guard let de = notification?.userInfo?[BLEKey.device] as? BLEDevice, de == self.device else {
            return
        }
        
        guard let uuid = notification?.userInfo?[BLEKey.uuid] as? String, uuid == UUID.nordicOtaBat else {
            return
        }
        
        guard let data = notification?.userInfo?[BLEKey.data] as? Data, data.count >= 2 else {
            return
        }
        
        print("设备回传：\(data.hexEncodedString())")
        
        let bytes = data.bytes
        
        let i = bytes[0]
        let m = bytes[1]
        var n = 0
        if bytes.count >= 3 {
            n = Int(bytes[2])
        }
        
        if i == 6 && m == 0 {
            // 成功了
            otaFinish()
        }
        else if i == 0x10 && m == 1 && n == 1 {
            sendInitData()
        }
        else if i == 0x10 && m == 2 && n == 1 {
            sendOtaBinData()
        }
        else if i == 0x11 {
            otaDatas[0].sections.remove(at: 0)
            
            sendPackages()
        }
        else if i == 0x10 && m == 9 && n == 1 {
            sendTypeData()
        }
        else if i == 0x10 && m == 3 && n == 1 {
            sendFileEnd()
        }
        else if i == 0x10 && m == 4 && n == 1 {
            if otaDatas.count > 0 {
                otaDatas.remove(at: 0)
            }
            
            if otaDatas.count > 0 {
                sendTypeData()
            } else {
                sendOtaEnd()
            }
            
        }
        else {
            otaFailed(error: BLEError.taskError(reason: .dataError))
        }
    }
    
    // MARK: - 工具
    
}
