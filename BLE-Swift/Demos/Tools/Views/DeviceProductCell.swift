//
//  DeviceProductCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceProductCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(withProduct product: DeviceProduct) {
        nameLbl.text = product.name
        timeLbl.text = String.timeString(fromTimeInterval: product.createTime)
    }
    
}
