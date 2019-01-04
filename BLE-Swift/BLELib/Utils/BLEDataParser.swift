//
//  BLEDataParser.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol BLEDataParserProtocol: NSObjectProtocol {
    func didFinishParser(data: Data, dataArr: Array<Data>, recvCount: Int)
}

class BLEDataParser: NSObject {

    var tmpData = Data()
    var tmpDataArr = Array<Data>()
    var recvLength = 0
    weak var delegate: BLEDataParserProtocol?
    
    func clear() {
        tmpData.removeAll()
        tmpDataArr.removeAll()
        recvLength = 0
    }
    
    func standardParse(data: Data, sendData: Data, recvCount: Int = 1) {
        
        let sendBytes = sendData.bytes
        let recvBytes = data.bytes
        
        // 目前只支持新协议
        // 如果开头是 0x6f，可能是开头，如果是 0x6f + 指令码 + 0x80 那就是开头了
        if recvBytes[0] == 0x6f && recvBytes.count > 2 {
            
            if recvBytes[1] == sendBytes[1] {
                // 模版：0x6f 0x02 0x80 0x00 0x00 0x8f
                // 具体含义，请查看appscomm蓝牙协议文档
                if (recvBytes[2] == 0x80 || recvBytes[2] == 0x81) && recvBytes.count >= 6 {
                    
                    // 查询指令，接下来两位是数据长度
                    recvLength = Int(recvBytes[3]) + Int(recvBytes[4] << 8)
                    tmpData = data.subdata(in: 5..<data.count)
                    
                } else {
                    tmpData.append(data)
                }
                
            } else {
                tmpData.append(data)
            }
        }
        else
        {
            tmpData.append(data)
        }
        
        // 判断是否结束
        // +1 是因为，最后带了一个0x8f
        if tmpData.count >= (recvLength + 1) {
            // 最起码是单条结束了，如果是多条，另外处理
            // 去掉最后一个 0x8f
            tmpData = tmpData.subdata(in: 0..<tmpData.count - 1)
            tmpDataArr.append(tmpData)
            
            // 结束了
            if recvCount == tmpDataArr.count {
                delegate?.didFinishParser(data: tmpData, dataArr: tmpDataArr, recvCount: recvCount)
            }
            
        }
    }
    
}
