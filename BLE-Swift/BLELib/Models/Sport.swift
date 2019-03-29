//
//  Sport.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum SportType: Int, Codable {
    case other = 0
    case walk
    case run
    case situp
    case swin
    case ride
    case climbStairs
    case climbMountains
    case stand
    case sit
    case rideIndoor
    case weights            //举重
}

public class Sport: Codable {

    var index: UInt
    var type: SportType = .other
    var time: TimeInterval
    var step: UInt
    var calorie: UInt
    var distance: UInt
    var duration: UInt
    var avgBpm: UInt = 0
    
    init(index: UInt, time: TimeInterval, step: UInt, calorie: UInt, distance: UInt, duration: UInt) {
        self.index = index
        self.time = time
        self.step = step
        self.calorie = calorie
        self.distance = distance
        self.duration = duration
    }
    
    convenience init(index: UInt, type: SportType, time: TimeInterval, step: UInt, calorie: UInt, distance: UInt, duration: UInt) {
        self.init(index: index, time: time, step: step, calorie: calorie, distance: distance, duration: duration)
        self.type = type
    }
}
