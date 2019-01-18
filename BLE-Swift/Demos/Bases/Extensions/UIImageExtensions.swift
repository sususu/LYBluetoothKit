//
//  UIImageExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/17.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

extension UIImage {
    public static func color(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
