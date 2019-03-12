//
//  CircleTestGroupView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit


protocol CircleTestGroupViewDelegate: NSObjectProtocol {
    func cgvDidClickAdd(cg: CircleGroup)
    func cgvDidClickDel(cg: CircleGroup)
}

class CircleTestGroupView: UIView {

    private var index: Int
    
    weak var delegate: CircleTestGroupViewDelegate?
    
    private var cg: CircleGroup!
    
    convenience init(frame: CGRect, index: Int) {
        self.init(frame: frame)
        self.index = index
        setupViews()
    }
    
    override init(frame: CGRect) {
        self.index = 0
        super.init(frame: frame)
        backgroundColor = rgb(245, 245, 245)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nameLbl: UILabel!
    private var addTestBtn: UIButton!
    
    func setupViews() {
        nameLbl = UILabel(frame: CGRect(x: 15, y: 0, width: kScreenWidth, height: self.height))
        nameLbl.font = font(14)
        nameLbl.textColor = kMainColor
        addSubview(nameLbl)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: kScreenWidth - 60 - 15, y: (self.height - 30) / 2, width: 60, height: 30)
        btn.titleLabel?.font = font(12)
        btn.titleLabel?.textColor = UIColor.white
        btn.backgroundColor = kMainColor
        btn.layer.cornerRadius = 3
        btn.layer.masksToBounds = true
        btn.setTitle("添加操作", for: .normal)
        btn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside)
        addSubview(btn)
        
        
        let delBtn = UIButton(type: .custom)
        delBtn.frame = CGRect(x: btn.left - 60 - 10, y: (self.height - 30) / 2, width: 60, height: 30)
        delBtn.titleLabel?.font = font(12)
        delBtn.titleLabel?.textColor = UIColor.white
        delBtn.backgroundColor = rgb(200, 40, 40)
        delBtn.layer.cornerRadius = 3
        delBtn.layer.masksToBounds = true
        delBtn.setTitle("删除该组", for: .normal)
        delBtn.addTarget(self, action: #selector(delBtnClick), for: .touchUpInside)
        addSubview(delBtn)
    }
    
    func update(withCg cg: CircleGroup) {
        self.cg = cg
        nameLbl.text = cg.name + " - 重复次数：\(cg.repeatCount)"
    }
    
    @objc func addBtnClick() {
        delegate?.cgvDidClickAdd(cg: self.cg)
    }
    
    @objc func delBtnClick() {
        delegate?.cgvDidClickDel(cg: self.cg)
    }
    
}
