//
//  XFATPosition.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/

import UIKit

class XFATPosition: NSObject {
//    convenience init(count: Int, index: Int) {
//        self.init(count: count, index: index)
//    }
    
    var count: Int = 0
    var index: Int = 0
    var center = CGPoint.zero
    var frame = CGRect.zero
    
    required init(count: Int, index: Int) {
        super.init()
        
        self.count = count < 0 ? 0 : count
        self.count = self.count > XFATLayoutAttributes.maxCount() ? XFATLayoutAttributes.maxCount() : self.count
        self.index = index < 0 ? 0 : index
        self.index = self.index > self.count ? XFATLayoutAttributes.maxCount() : self.index
        center = getCenter()
        frame = getFrame()
        
    }

    override convenience init() {
        self.init(count: 0, index: 0)
    }
    
    func getCenter() -> CGPoint {
        //If count is zero ,make contentItem spread to (1,1)
        var count = self.count
        var index = self.index
        if self.count == 0 {
            count = 1
            index = 1
        }
        let angle: Double = 5 * Double.pi/2 - .pi * 2 / Double(count) * Double(index)
        let k = tan(angle)
        var x: Double
        var y: Double
        if Double.pi/4 * 9 < angle || angle <= Double.pi/4 * 3 {
            y = Double(XFATLayoutAttributes.itemWidth())
            if angle == Double.pi/2 * 5 || angle == Double.pi/2 * 3 {
                x = 0
            } else {
                x = y / k
            }
        } else if Double.pi/4 * 7 < angle && angle <= Double.pi/4 * 9 {
            x = Double(XFATLayoutAttributes.itemWidth())
            y = k * x
        } else if Double.pi/4 * 5 < angle && angle <= Double.pi/4 * 7 {
            y = -Double(XFATLayoutAttributes.itemWidth())
            if angle == Double.pi/2 * 5 || angle == Double.pi/2 * 3 {
                x = 0
            } else {
                x = y / k
            }
        } else if Double.pi/4 * 3 < angle && angle <= Double.pi/4 * 5 {
            x = -Double(XFATLayoutAttributes.itemWidth())
            y = k * x
        }
        else {
            x = 0
            y = 0
        }
        let center = coordinatesTransform(CGPoint(x: x, y: y))
        return center
    }
    
    func getFrame() -> CGRect {
        let center: CGPoint = self.center
        let frame = CGRect(x: center.x - XFATLayoutAttributes.itemWidth() / 2, y: center.y - XFATLayoutAttributes.itemWidth() / 2, width: XFATLayoutAttributes.itemWidth(), height: XFATLayoutAttributes.itemWidth())
        return frame
    }
    
    func coordinatesTransform(_ point: CGPoint) -> CGPoint {
        var point = point
        let rect: CGRect = UIScreen.main.bounds
        let screenCenter = CGPoint(x: rect.midX, y: rect.midY)
        point.y = -point.y
        let transformPoint = CGPoint(x: screenCenter.x + point.x, y: screenCenter.y + point.y)
        return transformPoint
    }
    
//    override class func description() -> String {
//        return String(format: "%@ <count:%ld index:%ld>", super.description(), count, index)
//    }
}
