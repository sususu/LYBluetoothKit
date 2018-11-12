//
//  DeviceCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/11/5.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var rssiLbl: UILabel!
    
    func updateUI(withDevice device:BLEDevice) {
        nameLbl.text = device.name
        rssiLbl.text = "\(device.rssi ?? 0)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
