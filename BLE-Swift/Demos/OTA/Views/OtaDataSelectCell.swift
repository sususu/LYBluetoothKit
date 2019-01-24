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
            nameLbl.text = TR("FW")
            nameLbl.backgroundColor = rgb(200, 30, 30)
        case .picture:
            nameLbl.text = TR("PIC")
            nameLbl.backgroundColor = rgb(30, 30, 200)
        case .heartRate:
            nameLbl.text = TR("HR")
            nameLbl.backgroundColor = rgb(230, 10, 10)
        case .touchPanel:
            nameLbl.text = TR("TP")
            nameLbl.backgroundColor = rgb(30, 200, 30)
        case .freeScale:
            nameLbl.text = TR("KL")
            nameLbl.backgroundColor = UIColor.purple
        case .agps:
            nameLbl.text = TR("GP")
            nameLbl.backgroundColor = UIColor.blue
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
