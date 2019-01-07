//
//  ProtocolJsonParser.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProtocolJsonParser: NSObject {
    public static let shared = ProtocolJsonParser()
    
    
    func parser(jsonFileName: String) -> Array<ProtocolMenu> {
        
        var arr = Array<ProtocolMenu>()
        
        let path = Bundle.main.path(forResource: jsonFileName, ofType: nil)
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path ?? ""))
        
            let json = try JSON(data: jsonData)
            print(json)
            guard let jsonArr = json.array else {
                return arr
            }
            
            for j in jsonArr {
                let name = j["name"].string ?? ""
                let pm = ProtocolMenu(name: name)
                arr.append(pm)
                
                guard let parr = j["protocols"].array else {
                    continue
                }
                pm.protocols = parserProtocolArray(jsons: parr)
            }
            
        }
        catch {
            print("json parser exception: \(error)")
        }
        
        return arr
    }
    
    // 解析 protocol array
    func parserProtocolArray(jsons: [SwiftyJSON.JSON]) -> Array<Protocol> {
        
        var protocols = Array<Protocol>()
        for j in jsons {
            
            let name = j["name"].string ?? ""
            let code = j["code"].string ?? ""
            let summary = j["summary"].string ?? ""
            let cmd = j["cmd"].string ?? ""
            
            let p = Protocol()
            p.name = name
            p.code = code
            p.summary = summary
            p.cmd = cmd
            
            if let rfDict = j["returnFormat"].dictionary {
                p.returnFormat = parserReturnFormat(dict: rfDict)
            } else {
                p.returnFormat = boolReturnFormat()
            }
            protocols.append(p)
        }
        
        return protocols
    }
    
    
    func parserReturnFormat(dict: Dictionary<String, JSON>) -> ReturnFormat {
        
        let type = dict["type"]!.stringValue
        let length = dict["length"]!.intValue
        let byteFlag = dict["byteFlag"]!.intValue
        
        let rf = ReturnFormat()
        rf.type = type
        rf.length = length
        rf.byteFlag = byteFlag
        
        if let subRf = dict["subFormat"]?.dictionary {
            rf.subFormat = parserReturnFormat(dict: subRf)
        }
        
        return rf
    }
    
    
}
