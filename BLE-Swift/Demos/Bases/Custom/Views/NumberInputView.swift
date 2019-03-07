//
//  NumberInputView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class NumberInputView: UIControl {
    
    var textField: UITextField!
    var jiaBtn: UIButton!
    var jianBtn: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    func initViews() {
        let btnWidth = self.bounds.height
        let btnHeight = self.bounds.height
        
        jianBtn = UIButton(type: .custom)
        jianBtn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        jianBtn.setTitle(TR("-"), for: .normal)
        jianBtn.layer.cornerRadius = 4
        jianBtn.layer.masksToBounds = true
        
        jianBtn.addTarget(self, action: #selector(jianBtnClick), for: .touchUpInside)
        addSubview(jianBtn)
        
        textField = UITextField(frame: CGRect(x: btnWidth, y: 0, width: self.bounds.width - btnWidth * 2, height: btnHeight))
//        textField.keyboardType = .numberPad
        textField.text = "0"
//        textField.borderStyle = .line
        textField.font = font(14)
        textField.borderStyle = .roundedRect
//        textField.layer.borderColor = rgb(200, 200, 200).cgColor
//        textField.layer.borderWidth = 1
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        addSubview(textField)
        
        jiaBtn = UIButton(type: .custom)
        jiaBtn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        jiaBtn.setTitle(TR("+"), for: .normal)
        jiaBtn.addTarget(self, action: #selector(jiaBtnClick), for: .touchUpInside)
        jiaBtn.layer.cornerRadius = 4
        jiaBtn.layer.masksToBounds = true
        addSubview(jiaBtn)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let btnWidth = self.bounds.height
        let btnHeight = self.bounds.height
        jianBtn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        textField.frame = CGRect(x: btnWidth, y: 0, width: self.bounds.width - btnWidth * 2, height: btnHeight)
        jiaBtn.frame = CGRect(x: textField.right, y: 0, width: btnWidth, height: btnHeight)
        
        if self.width > 0 && self.height > 0 {
            jianBtn.setBackgroundImage(UIImage.color(color: kMainColor, size: jianBtn.bounds.size), for: .normal)
            jianBtn.setBackgroundImage(UIImage.color(color: rgb(180, 180, 180), size: jianBtn.bounds.size), for: .highlighted)
            
            jiaBtn.setBackgroundImage(UIImage.color(color: kMainColor, size: jiaBtn.bounds.size), for: .normal)
            jiaBtn.setBackgroundImage(UIImage.color(color: rgb(180, 180, 180), size: jiaBtn.bounds.size), for: .highlighted)
        }
    }
    
    
    @objc func jiaBtnClick() {
        textField.text = "\((Int(textField.text ?? "0") ?? 0) + 1)"
    }
    
    @objc func jianBtnClick() {
        var val = (Int(textField.text ?? "0") ?? 0) - 1
        if val < 0 {
            val = 0
        }
        textField.text = "\(val)"
    }
}
