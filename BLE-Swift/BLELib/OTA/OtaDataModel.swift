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
    case freeScale
    case agps
}

public struct OtaDataModel {
    var type: OtaDataType
    var data: Data
    
    var otaAddressData: Data!
    var otaData: Data!
    var crcData: Data!
    var sections = [OtaDataSection]()
    
    var datData: Data!
    var typeData: Data!
    
    init(type: OtaDataType, data: Data) {
        self.type = type
        self.data = data
    }
    
    mutating func getApolloDataReady() -> Bool {
        
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
    
    
    mutating func getNordicDataReady() -> Bool {
        
        if type == .platform{
            self.otaData = data
            self.crcData = datData
            self.typeData = getNordicTypeData()
            self.sections = splitDataToSections(otaData)
            return true
        }
        
        guard let otaData = getNordicOtaData(for: data) else {
            return false
        }
        
        guard let addressData = getNordicOtaAddressData(for: data) else {
            return false
        }
        
        guard let crcData = getNordicCrcData(for: otaData) else {
            return false
        }
        
        self.otaData = otaData
        self.otaAddressData = addressData
        self.crcData = crcData
        self.typeData = getNordicTypeData()
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
    
    func getNordicOtaData(for data: Data) -> Data? {
        
        if type == .platform {
            return data
        }
        
        var offset = 5
        if type == .picture {
            offset = 4
        }
        if data.count <= offset {
            return nil
        }
        return data.subdata(in: offset ..< data.count)
    }
    
    func getNordicOtaAddressData(for data: Data) -> Data? {
        var offset = 5
        if type == .picture {
            offset = 4
        }
        if data.count < offset {
            return nil
        }
        return data.subdata(in: 0 ..< offset)
    }
    
    func getNordicTypeData() -> Data {
        switch type {
        case .platform:
            return Data(bytes: [0x01, 0x04])
        case .touchPanel:
            return Data(bytes: [0x01, 0x10])
        case .heartRate:
            return Data(bytes: [0x01, 0x20])
        case .picture:
            return Data(bytes: [0x01, 0x40])
        case .agps:
            return Data(bytes: [0x00, 0x00])
        case .freeScale:
            return Data(bytes: [0x01, 0x08])
        }
    }
    
    func getNordicCrcData(for data: Data) -> Data? {
        guard let crc = getCrcData(for: data) else {
            return nil
        }
        var tmpData = Data(bytes: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00])
        tmpData.append(crc)
        return tmpData
    }
    
}
