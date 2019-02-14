//
//  XFATLayoutAttributes.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
import UIKit

let IS_IPAD_IDIOM = UI_USER_INTERFACE_IDIOM() == .pad
let IS_IPHONE_IDIOM = UI_USER_INTERFACE_IDIOM() == .phone
//let IS_DEVICE_LANDSCAPE = UIDeviceOrientationIsLandscape(UIDeviceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
let IS_DEVICE_LANDSCAPE = (UIApplication.shared.statusBarOrientation.isLandscape)

class XFATLayoutAttributes: NSObject {
    class func contentViewSpreadFrame() -> CGRect {
        let spreadWidth: CGFloat = IS_IPAD_IDIOM ? 390 : 295
        let screenFrame: CGRect = UIScreen.main.bounds
        let frame = CGRect(x: (screenFrame.width - spreadWidth) / 2, y: (screenFrame.height - spreadWidth) / 2, width: spreadWidth, height: spreadWidth)
        return frame
    }
    
    class func cotentViewDefaultPoint() -> CGPoint {
        let screenFrame: CGRect = UIScreen.main.bounds
        let point = CGPoint(x: screenFrame.width - self.itemImageWidth() / 2 - self.margin(), y: screenFrame.midY)
        return point
    }
    
    class func itemWidth() -> CGFloat {
        return self.contentViewSpreadFrame().width / 3.0
    }
    
    class func itemImageWidth() -> CGFloat {
        return IS_IPAD_IDIOM ? 76 : 60
    }
    
    class func cornerRadius() -> CGFloat {
        return 14
    }
    
    class func margin() -> CGFloat {
        return 2
    }
    
    class func maxCount() -> Int {
        return 8
    }
    
    class func inactiveAlpha() -> CGFloat {
        return 0.4
    }
    
    class func animationDuration() -> CGFloat {
        return 0.25
    }
    
    class func activeDuration() -> CGFloat {
        return 4
    }
    
    // iPad   width 390 itemWidth 76 margin 2 corner:14  48-41-33
    // iPhone width 295 itemWidth 60 margin 2 corner:14  44-38-30
}
