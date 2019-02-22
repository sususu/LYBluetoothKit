//
//  OtaService.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kFirmwareListCacheKey = "kFirmwareListCacheKey"
let kConfigListCacheKey = "kConfigListCacheKey"
let kPrefixListCacheKey = "kPrefixListCacheKey"

class OtaService {
    
    static let shared = OtaService()
    
    var configs: [OtaConfig] = []
    var firmwares: [Firmware] = []
    var prefixs: [OtaPrefix] = []
    
    init() {
        
        firmwares = readFmsFromDisk()
        configs = readConfigsFromDisk()
        
    }
    
    private func readFmsFromDisk() -> [Firmware] {
        if let fmJsonData = StorageUtils.getData(forKey: kFirmwareListCacheKey) {
            do {
                let tmp: [Firmware] = try JSONDecoder().decode([Firmware].self, from: fmJsonData)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("firmware json decode error: \(err)")
            }
        }
        return []
    }
    
    private func readConfigsFromDisk() -> [OtaConfig] {
        if let configJsonData = StorageUtils.getData(forKey: kConfigListCacheKey) {
            do {
                let tmp: [OtaConfig] = try JSONDecoder().decode([OtaConfig].self, from: configJsonData)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("otaConfig json decode error: \(err)")
            }
        }
        return []
    }
    
    
    private func saveFmsToDisk() {
        do {
            let data = try JSONEncoder().encode(firmwares)
            StorageUtils.save(data, forKey: kFirmwareListCacheKey)
        } catch let err {
            print("firmware json encode error: \(err)")
        }
    }
    
    func readPrefixsFromDisk() -> [OtaPrefix] {
        var configJsonData = StorageUtils.getData(forKey: kPrefixListCacheKey)
        if configJsonData == nil {
            if let path = Bundle.main.path(forResource: "otaPrefix", ofType: "json") {
                do {
                    configJsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                }
                catch {}
            }
        }
        if configJsonData != nil {
            do {
                let tmp: [OtaPrefix] = try JSONDecoder().decode([OtaPrefix].self, from: configJsonData!)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("otaPrefix json decode error: \(err)")
            }
        }
        return []
    }
    
    func saveConfigsToDisk() {
        do {
            let data = try JSONEncoder().encode(configs)
            StorageUtils.save(data, forKey: kConfigListCacheKey)
        } catch let err {
            print("otaConfig json encode error: \(err)")
        }
    }
    
    func savePrefixsToDisk() {
        do {
            let data = try JSONEncoder().encode(prefixs)
            StorageUtils.save(data, forKey: kPrefixListCacheKey)
        } catch let err {
            print("otaConfig json encode error: \(err)")
        }
    }
    
    
    func getConfigs() -> [OtaConfig] {
        return []
    }
    
    func isConfigExit(config: OtaConfig) -> Bool {
        return true
    }
    
    func saveConfig(config: OtaConfig) {
        
    }
    
    func saveConfigs(configs: [OtaConfig]) {
        
    }
    
    func saveFirmware(_ fm: Firmware) {
        firmwares.insert(fm, at: 0)
        saveFmsToDisk()
    }
    
    func deleteFirmware(_ fm: Firmware) {
        firmwares.remove(fm)
        saveFmsToDisk()
    }
}
