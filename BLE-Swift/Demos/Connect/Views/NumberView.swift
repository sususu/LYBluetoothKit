//
//  NumberView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/16.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

class NumberView: UIControl {

    var num:Int = 0 {
        
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.numLbl.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.numLbl.text = "\(self.num)"
                UIView.animate(withDuration: 0.4, animations: {
                    self.numLbl.layer.transform = CATransform3DMakeScale(1, 1, 1)
                })
                
            }
        }
    }
    
    var numLbl = UILabel(frame: CGRect.zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        numLbl.frame = CGRect(x: frame.width / 4, y: frame.height / 4, width: frame.width / 2, height: frame.height / 2)
        numLbl.font = font(14)
        numLbl.textAlignment = .center
        numLbl.layer.cornerRadius = numLbl.frame.height / 2
        numLbl.layer.masksToBounds = true
        numLbl.text = "\(num)"
        numLbl.backgroundColor = UIColor.red
        numLbl.textColor = UIColor.white
        self.addSubview(numLbl)
        
        let btn = UIButton(type: .custom)
        btn.frame = self.bounds
        btn.addTarget(self, action: #selector(selfClick), for: .touchUpInside)
        self.addSubview(btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func selfClick() {
        self.sendActions(for: .touchUpInside)
    }
}
