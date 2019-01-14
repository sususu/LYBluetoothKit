//
//  FirmwareSelectCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class FirmwareSelectCell: UITableViewCell {
    
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var createTimeLbl: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    func updateUI(withFirmware firmware: Firmware) {
        nameLbl.text = firmware.name
        createTimeLbl.text = Date(timeIntervalSince1970: firmware.createTime).description
        versionLbl.text = firmware.versionName
        
        switch firmware.type {
        case .platform:
            typeLbl.text = TR("FW")
            typeLbl.backgroundColor = rgb(200, 30, 30)
        case .picture:
            typeLbl.text = TR("PIC")
            typeLbl.backgroundColor = rgb(30, 30, 200)
        case .heartRate:
            typeLbl.text = TR("HR")
            typeLbl.backgroundColor = rgb(230, 10, 10)
        case .touchPanel:
            typeLbl.text = TR("TP")
            typeLbl.backgroundColor = rgb(30, 200, 30)
        default:
            typeLbl.text = TR("UK")
            typeLbl.backgroundColor = rgb(150, 150, 150)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }
    
    
}
