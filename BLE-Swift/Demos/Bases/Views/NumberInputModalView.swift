//
//  NumberInputModalView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class NumberInputModalView: UIView {

    private static var sharedView: NumberInputModalView?
    
    static func show(withOkCallback okCallback: ((Int)->Void)?) {
        if let old = sharedView {
            old.removeFromSuperview()
        }
        sharedView = NumberInputModalView(frame: UIScreen.main.bounds)
        sharedView?.setupViews()
        sharedView?.okCallback = okCallback
        sharedView?.show()
    }
    
    static func setOldParam(_ oldParam: Param) {
        
        guard let sv = sharedView else {
            return
        }
        
        sv.titleLbl.text = oldParam.label
        sv.numberInputView.textField.text = oldParam.value
        
    }
    
    private var okCallback: ((Int)->Void)?
    
    private var contentView: UIView!
    
    private var titleLbl: UILabel!
    private var numberInputView: NumberInputView!
    
    private func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    private func hide() {
        okCallback = nil
        self.removeFromSuperview()
    }
    
    private func setupViews() {
        
        backgroundColor = rgb(0, 0, 0, 0.8)
        
        contentView = UIView(frame: self.bounds.inset(by: UIEdgeInsets(top: 100, left: 40, bottom: self.height - 100 - 200, right: 40)))
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        
        titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.width, height: 40))
        titleLbl.backgroundColor = rgb(240, 240, 240)
        titleLbl.textColor = rgb(240, 60, 60)
        titleLbl.font = bFont(16)
        titleLbl.textAlignment = .center
        contentView.addSubview(titleLbl)
        
        numberInputView = NumberInputView(frame: CGRect(x: 10, y: titleLbl.bottom + 10, width: contentView.width - 20, height: 40))
        contentView.addSubview(numberInputView)
        
        let okBtn = UIButton(type: .custom)
        okBtn.frame = CGRect(x: contentView.width - 80 - 5, y: contentView.height - 35, width: 80, height: 30)
        okBtn.backgroundColor = kMainColor
        okBtn.setTitle("确定", for: .normal)
        okBtn.layer.cornerRadius = 3
        okBtn.layer.masksToBounds = true
        okBtn.titleLabel?.font = font(14)
        okBtn.addTarget(self, action: #selector(okBtnClick), for: .touchUpInside)
        contentView.addSubview(okBtn)
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: okBtn.left - 80 - 10, y: contentView.height - 35, width: 80, height: 30)
        cancelBtn.backgroundColor = rgb(150, 40, 40)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.layer.masksToBounds = true
        cancelBtn.titleLabel?.font = font(14)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        contentView.addSubview(cancelBtn)
    }
    
    @objc private func okBtnClick() {
        let result = Int(numberInputView.textField.text ?? "" ) ?? 0
        okCallback?(result)
        hide()
    }
    
    @objc private func cancelBtnClick() {
        hide()
    }
}
