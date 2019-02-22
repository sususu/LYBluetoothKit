//
//  ProtocolService.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/26.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolService {

    private var kMenusCacheKey = "kMenusCacheKey"
    
    static let shared = ProtocolService()
    
    
    var protocolMenus: [ProtocolMenu] = []
    
    private init() {
        protocolMenus = readMenusFromDisk()
    }
    
    private func readMenusFromDisk() -> [ProtocolMenu] {
        var configJsonData = StorageUtils.getData(forKey: kMenusCacheKey)
        if configJsonData == nil {
            if let path = Bundle.main.path(forResource: "Protocol", ofType: "json") {
                do {
                    configJsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                }
                catch {}
            }
        }
        if configJsonData != nil {
            do {
                let tmp: [ProtocolMenu] = try JSONDecoder().decode([ProtocolMenu].self, from: configJsonData!)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("deviceProduct json decode error: \(err)")
            }
        }
        return []
    }
    
    func addMenu(menu: ProtocolMenu) {
        protocolMenus.insert(menu, at: 0)
        saveMenus()
    }
    
    func deleteMenu(menu: ProtocolMenu) {
        protocolMenus.remove(menu)
        saveMenus()
    }
    
    func saveMenus() {
        do {
            let data = try JSONEncoder().encode(protocolMenus)
            StorageUtils.save(data, forKey: kMenusCacheKey)
        } catch let err {
            print("protocolMenus json encode error: \(err)")
        }
    }
}
