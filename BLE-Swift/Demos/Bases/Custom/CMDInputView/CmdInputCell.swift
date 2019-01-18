//
//  CmdInputCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/16.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class CmdInputCell: UICollectionViewCell {
    
    private var lineHeight: CGFloat = 1
    private var lineColor: UIColor = rgb(200, 200, 200)
    private var cursorTintColor: UIColor = rgb(150, 30, 30)
    
    var cursor: UIView!
    var line: UIView!
    var textLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLbl.frame = self.bounds
        cursor.frame = CGRect(x: self.bounds.width / 2 - 0.5, y: 2, width: 1, height: self.bounds.height - 4)
        line.frame = CGRect(x: 3, y: self.bounds.height - lineHeight, width: self.bounds.width - 6, height: lineHeight)
    }
    
    func initViews() {
        textLbl = UILabel()
        textLbl.textAlignment = .center
        textLbl.textColor = kMainColor
        textLbl.font = font(10)
        
        cursor = UIView(frame: self.bounds)
        cursor.backgroundColor = cursorTintColor
        cursor.isHidden = true
        line = UIView(frame: CGRect(x: 3, y: self.bounds.height - lineHeight, width: self.bounds.width - 6, height: lineHeight))
        line.backgroundColor = lineColor
        
        addSubview(textLbl)
        addSubview(line)
        addSubview(cursor)
    }
    
    func updateUI(withCmdUnit cmdUnit: CmdUnit) {
        textLbl.text = cmdUnit.valueStr
        if cmdUnit.valueStr != nil && cmdUnit.valueStr!.count > 0 {
            cursor.isHidden = true
            cursor.layer.removeAnimation(forKey: "kAnimationKey")
        } else {
            cursor.isHidden = false
            cursor.layer.add(createAnimation(), forKey: "kAnimationKey")
        }
    }
    
    
    func createAnimation() -> CABasicAnimation {
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1.0;
        anim.toValue = 0.0;
        anim.duration = 0.9;
        anim.repeatCount = HUGE;
        anim.isRemovedOnCompletion = true;
        anim.fillMode = .forwards;
        anim.timingFunction = CAMediaTimingFunction(name: .easeIn)
        return anim
    }
    
}
