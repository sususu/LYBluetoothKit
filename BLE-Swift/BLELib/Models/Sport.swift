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

    var index: Int
    var type: SportType = .other
    var time: TimeInterval
    var step: Int
    var calorie: Int
    var distance: Int
    var duration: Int
    var avgBpm: Int = 0
    
    init(index: Int, time: TimeInterval, step: Int, calorie: Int, distance: Int, duration: Int) {
        self.index = index
        self.time = time
        self.step = step
        self.calorie = calorie
        self.distance = distance
        self.duration = duration
    }
    
    convenience init(index: Int, type: SportType, time: TimeInterval, step: Int, calorie: Int, distance: Int, duration: Int) {
        self.init(index: index, time: time, step: step, calorie: calorie, distance: distance, duration: duration)
        self.type = type
    }
}
