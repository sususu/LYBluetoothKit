//
//  OtaDataSelectCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaDataSelectCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var dataTextView: UITextView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLbl.layer.cornerRadius = 20
        nameLbl.layer.masksToBounds = true
    }

    
    func updateUI(withStr str: String, type: OtaDataType) {
        dataTextView.text = str
        switch type {
        case .platform:
            nameLbl.text = TR("固件")
            nameLbl.backgroundColor = rgb(200, 30, 30)
        case .picture:
            nameLbl.text = TR("字库")
            nameLbl.backgroundColor = rgb(30, 30, 200)
        case .heartRate:
            nameLbl.text = TR("心率")
            nameLbl.backgroundColor = rgb(230, 10, 10)
        case .touchPanel:
            nameLbl.text = TR("触摸")
            nameLbl.backgroundColor = rgb(30, 200, 30)
        default:
            nameLbl.text = TR("未知")
            nameLbl.backgroundColor = rgb(150, 150, 150)
        }
    }
    
    func updateUI(withFirmwares firmwares: [Firmware], type: OtaDataType) {
        var str = ""
        for f in firmwares {
            str += f.name
            str += "\n"
        }
        updateUI(withStr: str, type: type)
    }
    
}
