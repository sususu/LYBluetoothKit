//
//  ProtocolRunner.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit




class ProtocolRunner {

    func run(_ pcl: Protocol,
             boolCallback: ((Bool)->Void)?,
             stringCallback: ((String)->Void)?,
             dictCallback: ((Dictionary<String, Any>)->Void)?,
             dictArrayCallback: ((Array<Dictionary<String, Any>>)->Void)?,
             errorCallback: ((BLEError)->Void)?) {
        
        if let sendData = getCmdData(pcl: pcl) {
            BLECenter.shared.send(data: sendData, recvCount: pcl.returnCount, dataArrayCallback: { (datas, err) in
                
                if err != nil {
                    errorCallback?(err!)
                    return
                }
                
                if pcl.isBoolReturn {
                    var bool = false
                    if let arr = datas, arr.count > 0, arr[0].count >= 2 {
                        bool = (arr[0].bytes[1] == 0)
                    }
                    boolCallback?(bool)
                }
                else if pcl.isStringReturn {
                    var str = ""
                    if let arr = datas, arr.count > 0 {
                        str = String(bytes: arr[0], encoding: String.Encoding.utf8) ?? ""
                    }
                    stringCallback?(str)
                }
                else if pcl.isSplitReturn {
                    
                    guard let expression = pcl.returnFormat.expression, let arr = datas, arr.count > 0 else {
                        dictCallback?(Dictionary<String, Any>())
                        return
                    }
                    
                    var resultArr = Array<Dictionary<String, Any>>()
                    
                    for i in 0 ..< pcl.returnCount {
                        resultArr.append(self.parseDataToDict(data: arr[i], expression: expression))
                    }
                    
                    if resultArr.count > 1 {
                        dictArrayCallback?(resultArr)
                    } else {
                        dictCallback?(resultArr[0])
                    }
                    
                }
                
            }, toDeviceName: nil)
        } else {
            errorCallback?(BLEError.taskError(reason: .paramsError))
        }
        
    }
    
    func getCmdData(pcl: Protocol) -> Data? {

        var data = Data()
        for unit in pcl.cmdUnits {
            if unit.type == .cmd {
                guard let ud = unit.valueStr?.hexadecimal else {
                    continue
                }
                data.append(ud)
            }
            else if unit.type == .variable {
                data.append(getUnitData(unit: unit))
//                guard let param = unit.param else {
//                    continue
//                }
//
//
//                if let pd = param.value?.hexadecimal {
//                    data.append(pd)
//                }
            }
        }
        
        var len = data.count - 6
        if len > 0 {
            let lenData = Data(bytes: &len, count: 2)
            data.replaceSubrange(3 ..< 5, with: lenData)
        }
        
        return data
    }
    
    func getUnitData(unit: CmdUnit) -> Data {
        guard let str = unit.valueStr else {
            return Data()
        }
        
        if str.hasPrefix("Int") {
            guard let len = Int(str.suffix(1)), var intValue = Int(unit.param?.value ?? "") else {
                return Data()
            }
            return Data(bytes: &intValue, count: len)
        }
        else if str.hasPrefix("Str") {
            guard let strValue = unit.param?.value else {
                return Data()
            }
            return (strValue.data(using: .utf8) ?? Data())
        }
        else if str.hasPrefix("Len") {
            return Data(bytes: [0x00, 0x00])
        }
        else {
            return Data()
        }
    }
    
    
    func parseDataToDict(data: Data, expression: String) -> Dictionary<String, Any> {
        
        var dict = Dictionary<String, Any>()
        var index = 0
        
        let comps = expression.components(separatedBy: ",")
        for c in comps {
            let tmp = c.components(separatedBy: "-")
            if tmp.count > 2 {
                let len = Int(tmp[0]) ?? 0
                let name = tmp[1]
                let type = tmp[2]
                if data.count > index + len {
                    
                    if type == "Int" {
                        var intValue = 0
                        for i in 0 ..< len {
                            intValue += Int(data[index + i]) << (8 * i)
                        }
                        dict[name] = intValue
                        index += len
                        
                    } else {
                        if len == 0 {
                            let strData = data.subdata(in: index ..< data.count)
                            let str = String(bytes: strData, encoding: .utf8)
                            dict[name] = (str ?? "")
                            break
                        } else {
                            let strData = data.subdata(in: index ..< len + index)
                            let str = String(bytes: strData, encoding: .utf8)
                            dict[name] = (str ?? "")
                        }
                    }
                }
            }
        }
        
        return dict
    }
    
}
