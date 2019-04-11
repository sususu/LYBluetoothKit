//
//  DeviceTestSubjectView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestSubjectView: UICollectionReusableView {

    var nameLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nameLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.width - 20, height: self.height))
        nameLbl.font = bFont(12)
        nameLbl.textAlignment = .center
        nameLbl.textColor = rgb(220, 100, 100)
        addSubview(nameLbl)
        backgroundColor = rgb(230, 230, 230)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubject(_ subject: String) {
        nameLbl.text = subject
    }
    
}
