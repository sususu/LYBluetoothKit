//
//  ToolsService.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kDeviceProductListKey = "kDeviceProductListKey"

let kDeviceProductListChangedNotification = NSNotification.Name(rawValue: "kDeviceProductListChangedNotification")

class ToolsService {
    
    static let shared = ToolsService()
    
    var products: [DeviceProduct] = []
    
    private init() {
        products = readProductsFromDisk()
    }
    
    func refreshToolsFromDisk() {
        products = readProductsFromDisk()
        NotificationCenter.default.post(name: kDeviceProductListChangedNotification, object: nil)
    }
    
    func saveProduct(_ product: DeviceProduct) {
        if product.Id.count == 0 {
            product.Id = product.name + String.timeString(fromTimeInterval: product.createTime)
            addProduct(product)
        } else {
            updateProduct(product)
        }
    }
    
    private func addProduct(_ product: DeviceProduct) {
        products.insert(product, at: 0)
        saveProductsToDisk()
    }
    
    private func updateProduct(_ product: DeviceProduct) {
        for i in 0 ..< products.count {
            let p = products[i]
            if p.Id == product.Id {
                products[i] = p
                break
            }
        }
        saveProductsToDisk()
    }
    
    func deleteProduct(_ product: DeviceProduct) {
        for i in 0 ..< products.count {
            let p = products[i]
            if p.Id == product.Id {
                products.remove(at: i)
                break
            }
        }
        saveProductsToDisk()
    }
    
    
    private func readProductsFromDisk() -> [DeviceProduct] {
        var configJsonData = StorageUtils.getData(forKey: kDeviceProductListKey)
        if configJsonData == nil {
            if let path = Bundle.main.path(forResource: "DeviceProduct", ofType: "json") {
                do {
                    configJsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                }
                catch {}
            }
        }
        if configJsonData != nil {
            do {
                let tmp: [DeviceProduct] = try JSONDecoder().decode([DeviceProduct].self, from: configJsonData!)
                if tmp.count > 0 {
                    return tmp
                }
            } catch let err {
                print("deviceProduct json decode error: \(err)")
            }
        }
        return []
    }
    
    func saveProductsToDisk() {
        do {
            let data = try JSONEncoder().encode(products)
            StorageUtils.save(data, forKey: kDeviceProductListKey)
        } catch let err {
            print("deviceProduct json encode error: \(err)")
        }
    }
    
    func getJsonString() -> String {
        do {
            let data = try JSONEncoder().encode(products)
            return String(bytes: data.bytes, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    func getJsonData() -> Data? {
        do {
            let data = try JSONEncoder().encode(products)
            return data
        } catch {
            return nil
        }
    }
    
}
