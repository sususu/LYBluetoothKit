//
//  UIDefines.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/16.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

// MARK: - 常量
let kScreenWidth = UIScreen.main.bounds.width

let kScreenHeight = UIScreen.main.bounds.height

let kScale6 = kScreenWidth / 375.0

let kiPhoneX_S = (kScreenWidth >= 375 && kScreenHeight >= 812)

let kiPhoneXsMax = (kScreenWidth == 414 && kScreenHeight >= 896)

// 是否全屏手机
let kiFullScreen = kiPhoneX_S
// 状态栏高度
let kStatusBarHeight: CGFloat = (kiFullScreen ? 44 : 20)

// MARK: - 方法
func rgb(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 1) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func font(_ size:CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
}

func bFont(_ size:CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: size)
}

// 1296db
let kMainColor = rgb(0x12, 0x96, 0xdb)
