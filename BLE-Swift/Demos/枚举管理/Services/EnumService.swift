//
//  EnumService.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kEnumObjListKey = "kEnumObjListKey"

class EnumService {
    
    static let shared = EnumService()
    
    var enums: [EnumObj] = []
    
    private init() {
        enums = readEnumsFromDisk()
    }
    
    
    private func readEnumsFromDisk() -> [EnumObj] {
        let configJsonData = StorageUtils.getData(forKey: kEnumObjListKey)
        if configJsonData != nil {
            do {
                let tmp: [EnumObj] = try JSONDecoder().decode([EnumObj].self, from: configJsonData!)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("enums json decode error: \(err)")
            }
        }
        return []
    }
    
    func saveEnums() {
        do {
            let data = try JSONEncoder().encode(enums)
            StorageUtils.save(data, forKey: kEnumObjListKey)
        } catch let err {
            print("enums json encode error: \(err)")
        }
    }
}
