//
//  SplitLineView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SplitLineView: UIView {
    
    var typeLbl: UILabel!
    var nameTF: UITextField!
    var numberInput: NumberInputView!
    
    var type: ParamType = .int
    
    var name: String? {
        get {
            return nameTF.text?.filter({ (c) -> Bool in
                return c != "-"
            })
        }
    }
    
    var number: Int {
        get {
            return Int(numberInput.textField.text ?? "0") ?? 0
        }
    }
    
    var typeStr: String {
        get {
            return type == .int ? "Int" : "Str"
        }
    }
    
    convenience init(frame: CGRect, type: ParamType) {
        self.init(frame: frame)
        self.type = type
        
        if type == .int {
            typeLbl.text = "Int"
        } else {
            typeLbl.text = "Str"
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
        
        typeLbl = UILabel()
        typeLbl.font = font(10)
        typeLbl.backgroundColor = kMainColor
        typeLbl.textAlignment = .center
        typeLbl.textColor = UIColor.white
        typeLbl.layer.cornerRadius = 4
        typeLbl.layer.masksToBounds = true
        if type == .int {
            typeLbl.text = "Int"
        } else {
            typeLbl.text = "Str"
        }
        addSubview(typeLbl)
        
        nameTF = UITextField()
        nameTF.placeholder = TR("名称")
        nameTF.font = font(14)
        nameTF.borderStyle = .roundedRect
        addSubview(nameTF)
        
        numberInput = NumberInputView(frame: CGRect.zero)
        addSubview(numberInput)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        var typeWidth: CGFloat = 25
        var nameWidth: CGFloat = 80
        
        if kScreenWidth > 320 {
            typeWidth = 35
            nameWidth = 100
        }
        
        if kScreenWidth > 375 {
            typeWidth = 40
            nameWidth = 120
        }
        
        typeLbl.frame = CGRect(x: 0, y: 0, width: typeWidth, height: self.bounds.height)
        
        nameTF.frame = CGRect(x: typeLbl.right + 5, y: 0, width: nameWidth, height: self.bounds.height)
        numberInput.frame = CGRect(x: nameTF.right + 5, y: 0, width: self.width - nameTF.width - typeLbl.width - 10, height: self.bounds.height)
    }
    
}
