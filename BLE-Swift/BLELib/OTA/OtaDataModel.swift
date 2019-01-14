//
//  OtaDataModel.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

public enum OtaDataType: Int, Codable {
    case platform = 1
    case touchPanel
    case heartRate
    case picture
    case language
    case freeScale
}

public struct OtaDataModel {
    var type: OtaDataType
    var data: Data
    
    var otaAddressData: Data!
    var otaData: Data!
    var crcData: Data!
    var sections = [OtaDataSection]()
    
    init(type: OtaDataType, data: Data) {
        self.type = type
        self.data = data
    }
    
    mutating func getDataReady() -> Bool {
        
        guard let otaData = getOtaData(for: data) else {
            return false
        }
        
        guard let addressData = getOtaAddressData(for: data) else {
            return false
        }
        
        guard let crcData = getCrcData(for: otaData) else {
            return false
        }

        self.otaData = otaData
        self.otaAddressData = addressData
        self.crcData = crcData
        self.sections = splitDataToSections(otaData)
        
        return true
    }
    
    
    
    
    
    private func splitDataToSections(_ data: Data) -> [OtaDataSection] {
        var sections = [OtaDataSection]()
        let num = data.count / kSizeOfPieceData
        let left = data.count % kSizeOfPieceData
        for i in 0..<num {
            let data = data.subdata(in: i * kSizeOfPieceData ..< (i + 1) * kSizeOfPieceData)
            let section = OtaDataSection(data: data)
            sections.append(section)
        }
        if left > 0 {
            let data = data.subdata(in: data.count - left ..< data.count)
            let section = OtaDataSection(data: data)
            sections.append(section)
        }
        
        return sections
    }
    
    
    
    // MARK: - 工具
    func getCrcData(for sendData: Data) -> Data? {
        var crc: UInt16 = 0xffff
        let binBytes = sendData.bytes
        for i in 0..<(sendData.count) {
            
            crc = crc >> 8 | (crc << 8)
            
            crc ^= UInt16(binBytes[i])
            
            crc ^= UInt16((UInt8((crc & 0xff)) >> 4))
            
            crc ^= UInt16((crc << 8) << 4)
            
            crc ^= UInt16(((crc & 0xff) << 4) << 1)
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
    
    func getOtaData(for data: Data) -> Data? {
        if data.count <= 4 {
            return nil
        }
        return data.subdata(in: 4 ..< data.count)
    }
    
    func getOtaAddressData(for data: Data) -> Data? {
        if data.count < 4 {
            return nil
        }
        return data.subdata(in: 0 ..< 4)
    }
}
