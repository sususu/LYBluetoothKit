//
//  SplitLineView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SplitLineView: UIView {
    
    var nameTF: UITextField!
    var numberInput: NumberInputView!
    
    var name: String? {
        get {
            return nameTF.text
        }
    }
    
    var number: Int {
        get {
            return Int(numberInput.textField.text ?? "0") ?? 0
        }
    }

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
        nameTF.placeholder = TR("名称")
        nameTF.font = font(16)
        nameTF.borderStyle = .roundedRect
        addSubview(nameTF)
        
        numberInput = NumberInputView(frame: CGRect.zero)
        addSubview(numberInput)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        nameTF.frame = CGRect(x: 0, y: 0, width: 140, height: self.bounds.height)
        numberInput.frame = CGRect(x: nameTF.bounds.width + 10, y: 0, width: self.bounds.width - nameTF.bounds.width - 10, height: self.bounds.height)
    }
    
}
