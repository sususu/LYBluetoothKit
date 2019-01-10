//
//  OtaManager.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public class OtaManager {

    public func startOta(device: BLEDevice, otaDatas: [OtaDataModel], readyCallback: GetReadyBlock, progressCallback: FloatCallback, finishCallback: BoolCallback) {
        
        
        
    }
    
    
    
    // MARK: - 工具
    func crcData(for sendData: Data?) -> Data? {
        var crc: UInt16 = 0xffff
        let binBytes = sendData?.bytes
        for i in 0..<(sendData?.count ?? 0) {
            
            crc = UInt16(Int(UInt8(crc >> 8)) | (Int(crc) << 8))
            
            crc ^= UInt16(binBytes?[i] ?? 0)
            
            crc ^= UInt16(Int(UInt8(crc & 0xff)) >> 4)
            
            crc ^= UInt16((Int(crc) << 8) << 4)
            
            crc ^= UInt16(((Int(crc) & 0xff) << 4) << 1)
        }
        
        let dataCrc = Data(bytes: &crc, count: 2)
        let num: Int = 4 - dataCrc.count
        var zero: Int = 0
        if num == 0 {
            return dataCrc
        } else {
            var dataM = Data()
            dataM.append(dataCrc)
            dataM.append(Data(bytes: &zero, count: num))
            return dataM
        }
    }

    
    
}
