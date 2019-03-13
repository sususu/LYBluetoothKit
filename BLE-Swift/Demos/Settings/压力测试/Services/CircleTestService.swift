//
//  CircleTestService.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kDeviceTestConfigKey = "kDeviceTestConfigKey"

class CircleTestService {

    static let shared = CircleTestService()
    
    var configs: [DeviceTestConfig] = []
    
    private init() {
        
    }
    
    private func readConfigsFromDisk() -> [DeviceTestConfig] {
        let configJsonData = StorageUtils.getData(forKey: kDeviceTestConfigKey)
        if configJsonData != nil {
            do {
                let tmp: [DeviceTestConfig] = try JSONDecoder().decode([DeviceTestConfig].self, from: configJsonData!)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("DeviceTestConfig json decode error: \(err)")
            }
        }
        return []
    }
    
    func addConfig(_ config: DeviceTestConfig) {
        configs.insert(config, at: 0)
        saveConfigs()
    }
    
    func deleteConfig(_ config: DeviceTestConfig) {
        configs.remove(config)
        saveConfigs()
    }
    
    func saveConfigs() {
        do {
            let data = try JSONEncoder().encode(configs)
            StorageUtils.save(data, forKey: kDeviceTestConfigKey)
        } catch let err {
            print("DeviceTestConfig json encode error: \(err)")
        }
    }
}
