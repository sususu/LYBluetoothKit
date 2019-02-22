//
//  NetworkManager.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/18.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import LYNetwork

typealias NetworkCallback = (LYResponse)->Void

class NetworkManager {
    static let shared = NetworkManager()
    
    init() {
        
        LYNetworking.setApiBasePath(kTestBaseUrl)
        LYNetworking.setDebugLoggerSwitch(true)
        LYNetworking.setTimeoutInterval(30)

    }
    
    func get(_ url: String, params: Dictionary<String, Any>?, callback:@escaping NetworkCallback) {
        
        let p = params ?? [:]
        
        let pUrl = addParamsToUrl(url: url, params: p)
        
        let request = LYRequest(url: pUrl, parameters: p, method: .GET)
        request?.send(callback: { (resp) in
            var r = resp
            if r == nil {
                r = LYResponse()
                r!.code = emptyError.0
                r!.msg = emptyError.1
            }
            callback(r!)
        })
        
    }
    
    
    func post(_ url: String, params: Dictionary<String, Any>?, callback:@escaping NetworkCallback) {
        
        let p = params ?? [:]
        
        let pUrl = addParamsToUrl(url: url, params: p)
        
        let request = LYRequest(url: pUrl, parameters: p, method: .POST)
        request?.send(callback: { (resp) in
            var r = resp
            if r == nil {
                r = LYResponse()
                r!.code = emptyError.0
                r!.msg = emptyError.1
            }
            callback(r!)
        })
        
    }
    
    func addParamsToUrl(url: String, params:Dictionary<String, Any>) -> String {
        var pUrl = url + "?"
        for (key, value) in params {
            pUrl += "\(key)=\(value)&"
        }
        if params.keys.count > 0 {
            pUrl = String(pUrl.prefix(pUrl.count - 1))
        }
        return pUrl
    }
    
}
