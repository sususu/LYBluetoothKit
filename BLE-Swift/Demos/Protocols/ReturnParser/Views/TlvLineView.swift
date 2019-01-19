//
//  TlvLineView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TlvLineView: UIView {
    
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
        addSubview(nameTF)
        
        typeTF = UITextField()
        typeTF.font = font(16)
        typeTF.placeholder = TR("类型值")
        typeTF.textAlignment = .center
        addSubview(nameTF)
        
        lengthTF = UITextField()
        lengthTF.font = font(16)
        lengthTF.placeholder = TR("值长度")
        lengthTF.textAlignment = .center
        addSubview(lengthTF)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }

}
