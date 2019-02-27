//
//  OtaTlsrTask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaTlsrTask: OtaTask {
    
    private var isSingleOTAFinish = false

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
        for dm in otaDatas
        {
            if !dm.getTlsrDataReady() {
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
        let buf = Data(bytes: [0x01, 0xff])
        writeData(data: buf)
        // 芯片提供商的demo就是延迟0.01秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.startOta()
        }
    }
    
    private func startOta() {
        otaReady()
        
        let dm = otaDatas[0]
        startSendOtaData(dataModel: dm)
    }
    
    private func startSendOtaData(dataModel: OtaDataModel) {
        
        if self.state == .failed {
            return
        }
        
        let onceSendCount:Int = 1024 / 16
        
        for i in 0 ..< onceSendCount
        {
            if i == dataModel.tlsrOtaDataPackages.count - 1 {
                isSingleOTAFinish = true
                endOta()
                // 进度回调
                DispatchQueue.main.async {
                    self.progressCallback?(1)
                    NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
                }
                return
            }
            
            let sd = dataModel.tlsrOtaDataPackages[dataModel.tlsrOtaDataIndex + i]
            writeData(data: sd)
            
            // 进度回调
            let progress:Float = Float(dataModel.tlsrOtaDataIndex + i) / Float(dataModel.tlsrOtaDataPackages.count);
            DispatchQueue.main.async {
                self.progressCallback?(progress)
                NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
            }
            // 必须睡眠，否则ota失败，设备蓝牙速度慢
            Thread.sleep(forTimeInterval: 0.002)
        }
        dataModel.tlsrOtaDataIndex += onceSendCount
        print("index:\(dataModel.tlsrOtaDataIndex), count:\(dataModel.tlsrOtaDataPackages.count)")
        addTimer(timeout: 10, action: 2)
        readData()
    }
    
    
    private func endOta() {
        let buf = Data(bytes: [0x02, 0xff])
        writeData(data: buf)
        otaFinish()
    }
    
    
    func writeData(data: Data) {
        print("发送数据：\(data.hexEncodedString())")
        _ = self.device.write(data, characteristicUUID: UUID.tlsrOtaUuid)
    }
    
    func readData() {
        _ = self.device.read(characteristicUUID: UUID.tlsrOtaUuid)
    }
    
    
    // MARK: - 接收数据
    override func deviceDidUpdateData(data: Data, deviceName: String, uuid: String) {
        print("设备回传：\(data.hexEncodedString())")
        
        if deviceName != self.device.name || uuid != UUID.tlsrOtaUuid {
            return
        }
        
        if !self.isSingleOTAFinish {
            startSendOtaData(dataModel: otaDatas[0])
        }
    }
    
}
