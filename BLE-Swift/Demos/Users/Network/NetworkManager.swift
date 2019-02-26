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

        
        LYErrorCodeManager.shared()?.setMsg("无法连接服务器", forCode: -1004)
        //-1009
        LYErrorCodeManager.shared()?.setMsg("无法连接服务器", forCode: -1009)
        //-1011
        LYErrorCodeManager.shared()?.setMsg("无法连接服务器", forCode: -1011)
    }
    
    func get(_ url: String, params: Dictionary<String, Any>?, callback:@escaping NetworkCallback) {
        
        let p = params ?? [:]
        
        let pUrl = addParamsToUrl(url: url, params: p)
        
        LYNetworking.shared()?.setHTTPHeader(User.current.jwt, forKey: "jwt")
        
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
    
    
    func post(_ url: String, params: Dictionary<String, Any>?, callback:@escaping NetworkCallback, addParamToURL: Bool = true) {
        
        let p = params ?? [:]
        
        var pUrl = url
        if addParamToURL {
            pUrl = addParamsToUrl(url: url, params: p)
        }
        
        LYNetworking.shared()?.setHTTPHeader(User.current.jwt, forKey: "jwt")
        
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
            let valStr = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            pUrl += "\(key)=\(valStr)&"
        }
        if params.keys.count > 0 {
            pUrl = String(pUrl.prefix(pUrl.count - 1))
        }
        return pUrl
    }
    
}
