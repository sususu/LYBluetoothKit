//
//  FirmwareTypeCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class FirmwareTypeCell: UITableViewCell {
    
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(withType type: OtaDataType) {
        
        switch type {
        case .platform:
            nameLbl.text = "固件"
            typeLbl.text = TR("固")
            typeLbl.backgroundColor = rgb(200, 30, 30)
        case .picture:
            nameLbl.text = "字库"
            typeLbl.text = TR("字")
            typeLbl.backgroundColor = rgb(30, 30, 200)
        case .heartRate:
            nameLbl.text = "心率"
            typeLbl.text = TR("心")
            typeLbl.backgroundColor = rgb(230, 10, 10)
        case .touchPanel:
            nameLbl.text = "触摸"
            typeLbl.text = TR("触")
            typeLbl.backgroundColor = rgb(30, 200, 30)
        default:
            nameLbl.text = "不支持"
            typeLbl.text = TR("未知")
            typeLbl.backgroundColor = rgb(150, 150, 150)
        }
        
    }
    
    
    
}
