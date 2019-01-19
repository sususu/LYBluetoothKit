//
//  TlvLineView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TlvLineView: UIView, CmdKeyBoardViewDelegate {
    
    var nameTF: UITextField!
    var typeTF: UITextField!
    var lengthTF: UITextField!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    func initViews() {
        nameTF = UITextField()
        nameTF.font = font(16)
        nameTF.placeholder = TR("类型名称")
        nameTF.layer.borderColor = rgb(200, 200, 200).cgColor
        nameTF.layer.borderWidth = 1
        addSubview(nameTF)
        
        typeTF = UITextField()
        typeTF.font = font(16)
        typeTF.placeholder = TR("类型值")
        typeTF.textAlignment = .center
        let keyboard = CmdKeyBoardView()
        keyboard.delegate = self
        typeTF.inputView = keyboard
        typeTF.layer.borderColor = rgb(200, 200, 200).cgColor
        typeTF.layer.borderWidth = 1
        addSubview(typeTF)
        
        lengthTF = UITextField()
        lengthTF.font = font(16)
        lengthTF.placeholder = TR("值长度")
        lengthTF.textAlignment = .center
        lengthTF.layer.borderColor = rgb(200, 200, 200).cgColor
        lengthTF.layer.borderWidth = 1
        lengthTF.keyboardType = .numberPad
        addSubview(lengthTF)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = (self.width - 20) / 4
        let height = self.height
        
        let nameWidth = width * 2
        
        nameTF.frame = CGRect(x: 0, y: 0, width: nameWidth, height: height)
        typeTF.frame = CGRect(x: nameTF.right + 10, y: 0, width: width, height: height)
        lengthTF.frame = CGRect(x: typeTF.right + 10, y: 0, width: width, height: height)
        
    }

    func didEnterStr(str: String) {
        typeTF.text = (typeTF.text ?? "") + str
    }
    
    func didFinishInput() {
        typeTF.resignFirstResponder()
    }
    
    func didFallback() {
        var text = typeTF.text ?? ""
        if text.count > 0 {
            text = String(text.prefix(text.count - 1))
        }
        typeTF.text = text
    }
    
}
