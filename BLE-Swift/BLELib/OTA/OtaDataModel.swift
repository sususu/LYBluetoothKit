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
    case freeScale      // 只有Nordic平台才有 kl17
    case agps
}

public class OtaDataModel {
    var type: OtaDataType
    var data: Data
    
    var otaAddressData: Data!
    var otaData: Data!
    var crcData: Data!
    var sections = [OtaDataSection]()
    
    // 这两个也是为了兼容Nordic平台ota
    var datData: Data!
    var typeData: Data!
    
    // TLSR ota数据
    var tlsrOtaDataIndex = 0
    var tlsrOtaDataPackages: [Data]!
    
    init(type: OtaDataType, data: Data) {
        self.type = type
        self.data = data
    }
    
    func getApolloDataReady() -> Bool {
        
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
    
    
    func getNordicDataReady() -> Bool {
        
        if type == .platform{
            self.otaData = data
            self.crcData = datData
            self.typeData = getNordicTypeData()
            self.sections = splitNordicDataToSections(otaData)
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
        self.sections = splitNordicDataToSections(otaData)
        
        return true
    }
    
    func getTlsrDataReady() -> Bool {
        
        tlsrOtaDataIndex = 0
        tlsrOtaDataPackages = [Data]()
        
        if data.count == 0 {
            return false
        }
        
        let offset = 16
        
        var count = data.count / offset
        if data.count % offset > 0 {
            count += 1
        }
        
        for i in 0 ..< count {
            let start = i * offset
            let end = (i + 1) * offset > data.count ? data.count : (i + 1) * offset
            
            let subData = data.subdata(in: start ..< end)
            let subBytes = subData.bytes
            
            var pack_head = [UInt8](repeating: 0, count: 2)
            pack_head[0] = UInt8(i & 0xff)
            pack_head[1] = UInt8((i >> 8) & 0xff)
            
            var otaBuffer = [UInt8](repeating: 0, count: offset + 4)
            var otaCmd = [UInt8](repeating: 0, count: offset + 2)
            
            otaBuffer[0] = pack_head[0]
            otaBuffer[1] = pack_head[1]
            
            for j in 0 ..< offset {
                if j < subData.count {
                    otaBuffer[j + 2] = subBytes[j]
                } else {
                    otaBuffer[j + 2] = 0xff
                }
            }
            
            for j in 0 ..< offset + 2 {
                otaCmd[j] = otaBuffer[j]
            }
            
            let crc_t = getTlsrCrcData(for: otaCmd)
//            var crc = [UInt8](repeating: 0, count: 2)
//
//            crc[0] = UInt8(crc_t & 0xff)
//            crc[1] = UInt8((crc_t >> 8) & 0xff)
            
            otaBuffer[offset + 2] = UInt8(crc_t & 0xff)
            otaBuffer[offset + 3] = UInt8((crc_t >> 8) & 0xff)
            
            let pack = Data(bytes: otaBuffer, count: offset + 4)
            self.tlsrOtaDataPackages.append(pack)
            
        }
        
        return true
        
    }
    
    
    // apollo平台，ota 拆分数据是已 2048 为一块
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
    
    // nordic 没有分块的设计，只是设计成20的packages回传一次
    private func splitNordicDataToSections(_ data: Data) -> [OtaDataSection] {
        var sections = [OtaDataSection]()
        let sectionSize = kPackageCountCallback * BLEConfig.shared.mtu
        let num = data.count / sectionSize
        let left = data.count % sectionSize
        for i in 0..<num {
            let data = data.subdata(in: i * sectionSize ..< (i + 1) * sectionSize)
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
    
    /*
    let crc16Poly = [0, 0xa001] //0x8005 <==> 0xa001
    
    func crc16(pD: UInt8, len: Int) -> UInt16 {
        var crc: UInt16 = 0xffff
        var i: Int
        var j: Int
        j = len
        while j > 0 {
            var ds: UInt8 = pD += 1
            for i in 0..<8 {
                crc = (crc >> 1) ^ crc16Poly[(UInt(crc) ^ UInt(ds)) & 1]
                ds = ds >> 1
            }
            j -= 1
        }
        return crc
    }
 */
    
    func getTlsrCrcData(for bytes: [UInt8]) -> UInt16 {
        let crc16Poly: [UInt16] = [0, 0xa001]
        var crc: UInt16 = 0xffff
        
        var j = bytes.count
        while j > 0 {
            
            var ds = bytes[bytes.count - j]
            for _ in 0..<8 {
                crc = (crc >> 1) ^ crc16Poly[Int((crc ^ UInt16(ds)) & 1)]
                ds = ds >> 1
            }
            
            j -= 1
        }
        return crc
    }
    
}
