//
//  TestConfigCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/27.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TestConfigCell: UICollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLbl.layer.cornerRadius = 3
        nameLbl.layer.masksToBounds = true
        nameLbl.backgroundColor = rgb(150, 150, 150)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLbl.frame = self.bounds
    }

    func update(withDeviceTestUnit unit: DeviceTestUnit) {
        nameLbl.text = unit.name
        if unit.isZiCe {
            nameLbl.backgroundColor = kMainColor
        } else {
            nameLbl.backgroundColor = rgb(150, 150, 150)
        }
    }
    
}
