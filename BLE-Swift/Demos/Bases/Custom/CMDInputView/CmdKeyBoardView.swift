//
//  CmdKeyBoardView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/17.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol CmdKeyBoardViewDelegate: NSObjectProtocol {
    func didEnterStr(str: String)
    func didFinishInput()
    func didFallback()
}

class CmdKeyBoardView: UIView {

    var delegate: CmdKeyBoardViewDelegate?
    let keyboardHeight: CGFloat = 200
    
    
    var isSelectingLength = false
    
    let ds = ["D", "E", "F", "DONE",
              "A", "B", "C", "X",
              "7", "8", "9", "Str",
              "4", "5", "6", "Int",
              "1", "2", "3", "0"]
    let nums = ["1", "2", "3", "4",
                "5", "6", "7", "8", "9"]
    
    var btns = [UIButton]()
    
    init() {
        var bottomOffset: CGFloat = 0
        if kiPhoneX_S {
            bottomOffset = 34
        }
        let kbh: CGFloat = 200 + bottomOffset
        super.init(frame: CGRect(x: 0, y: kScreenHeight - kbh, width: kScreenWidth, height: kbh))
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initViews() {
        backgroundColor = UIColor.white
        
        
        let itemHeight = keyboardHeight / 5
        let itemWidth = self.bounds.width / 4
        
        // 增加按钮
        for i in 0 ..< ds.count {
            let x = CGFloat(i % 4) * itemWidth
            let y = CGFloat(i / 4) * itemHeight
            
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            btn.setTitle(ds[i], for: .normal)
            btn.titleLabel?.font = font(16)
            if i < 7 && i != 3 {
                btn.setTitleColor(kMainColor, for: .normal)
            } else if i == 11 || i == 15 {
                btn.setTitleColor(rgb(200, 30, 30), for: .normal)
            } else {
                btn.setTitleColor(rgb(30, 30, 30), for: .normal)
            }
            btn.setBackgroundImage(UIImage.color(color: UIColor.white, size: btn.bounds.size), for: .normal)
            btn.setBackgroundImage(UIImage.color(color: rgb(100, 100, 100), size: btn.bounds.size), for: .highlighted)
            btn.setTitleColor(rgb(200, 200, 200), for: .disabled)
            btn.setBackgroundImage(UIImage.color(color: rgb(200, 200, 200), size: btn.bounds.size), for: .disabled)
            btn.tag = i
            btn.addTarget(self, action: #selector(btnClick(button:)), for: .touchUpInside)
            
            addSubview(btn)
            
            btns.append(btn)
        }
        
        
        // 绘制横线
        for i in 0 ..< 4 {
            let y: CGFloat = CGFloat(i + 1) * itemHeight
            let line = UIView(frame: CGRect(x: 0, y: y, width: kScreenWidth, height: 0.5))
            line.backgroundColor = rgb(200, 200, 200)
            addSubview(line)
        }
        // 绘制竖线
        for i in 0 ..< 3 {
            let x: CGFloat = CGFloat(i + 1) * itemWidth
            let line = UIView(frame: CGRect(x: x, y: 0, width: 0.5, height: keyboardHeight))
            line.backgroundColor = rgb(200, 200, 200)
            addSubview(line)
        }
        
    }
    
    
    private func onlyEnableNumberKey() {

        for btn in btns {
            let str = ds[btn.tag]
            if !nums.contains(str) && str != "X" {
                btn.isEnabled = false
            }
        }
    }
    
    private func enableAllKey() {
        for btn in btns {
            btn.isEnabled = true
        }
    }
    
    // 事件处理
    @objc func btnClick(button: UIButton) {
        let str = ds[button.tag]
        if str == "DONE" {
            delegate?.didFinishInput()
        } else if str == "X" {
            if isSelectingLength {
                enableAllKey()
                isSelectingLength = false
            } else {
                delegate?.didFallback()
            }
        } else if str == "Str" {
            delegate?.didEnterStr(str: str)
        } else if str == "Int" {
            isSelectingLength = true
            onlyEnableNumberKey()
        } else {
            if isSelectingLength {
                delegate?.didEnterStr(str: "Int" + str)
                isSelectingLength = false
                enableAllKey()
            } else {
                delegate?.didEnterStr(str: str)
            }
        }
    }
}
