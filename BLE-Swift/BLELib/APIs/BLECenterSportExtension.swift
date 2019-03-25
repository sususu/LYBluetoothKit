//
//  BLECenterSportExtension.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

extension BLECenter {
    //(Array<Data>?, BLEError?)->Void
    public func getSportSleepDataNum(callback:((Int, Int, BLEError?)->Void)?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data(bytes: [0x6f,0x52,0x70,0x01,0x00,0x00,0x8f])
        return send(data: data, dataArrayCallback: { (datas, err) in
            if let error = err {
                callback?(0, 0, error)
            } else {
                guard let ds = datas, ds.count > 0, ds[0].count >= 4 else {
                    callback?(0, 0, BLEError.taskError(reason: .dataError))
                    return
                }
                let bytes = ds[0].bytes
                let sportNum = Int(bytes[0]) + Int((bytes[1] << 8))
                let sleepNum = Int(bytes[2]) + Int((bytes[3] << 8))
                callback?(sportNum, sleepNum, nil)
            }
        }, toDeviceName: deviceName)
    }
    
    public func getSportDetail(num: Int, callback:((Array<Sport>?, BLEError?)->Void)?, toDeviceName deviceName:String? = nil)->BLETask? {
        if num == 0 {
            callback?(nil, BLEError.taskError(reason: .paramsError))
            return nil
        }
        
        let data = Data(bytes: [0x6f,0x54,0x70,0x02,0x00,0x00,0x00,0x8f])
        return send(data: data, recvCount: num, dataArrayCallback: { (datas, err) in
            if let error = err {
                callback?(nil, error)
            } else {
                guard let ds = datas, ds.count > 0, ds[0].count >= 22 else {
                    callback?(nil, BLEError.taskError(reason: .dataError))
                    return
                }
                
                var sports = Array<Sport>()
                for d in ds {
                    if d.count < 22 {
                        callback?(nil, BLEError.taskError(reason: .dataError))
                        return
                    }
                    let bytes = d.bytes
                    let index = Int(bytes[0]) + Int((bytes[1] << 8))
                    let time = Int(bytes[2]) + Int((bytes[3]<<8)) + Int((bytes[4]<<16)) + Int((bytes[5]<<24))
                    let step = Int(bytes[6]) + Int((bytes[7]<<8)) + Int((bytes[8]<<16)) + Int((bytes[9]<<24))
                    let cal = Int(bytes[10]) + Int((bytes[11]<<8)) + Int((bytes[12]<<16)) + Int((bytes[13]<<24))
                    let dis = Int(bytes[14]) + Int((bytes[15]<<8)) + Int((bytes[16]<<16)) + Int((bytes[17]<<24))
                    let du = Int(bytes[18]) + Int((bytes[19]<<8)) + Int((bytes[20]<<16)) + Int((bytes[21]<<24))
                    
                    let sport = Sport(index: index, time: TimeInterval(time), step: step, calorie: cal, distance: dis, duration: du)
                    
                    if d.count >= 24 {
                        let avgHr = Int(bytes[22])
                        let type = Int(bytes[23])
                        sport.avgBpm = avgHr
                        sport.type = SportType(rawValue: type) ?? .other
                    }
                    
                    sports.append(sport)
                }
            
                callback?(sports, nil)
            }
        }, toDeviceName: deviceName)
    }
    
    public func deleteSportDatas(callback:BoolCallback?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data(bytes: [0x6f,0x53,0x71,0x01,0x00,0x00,0x8F])
        return send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
    
}
