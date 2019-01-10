//
//  PrefixCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class PrefixCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var bleLbl: UILabel!
    
    @IBOutlet weak var prefixLbl: UILabel!
    
    func updateUI(withPrefix prefix: OtaPrefix) {
        nameLbl.text = prefix.deviceName
        bleLbl.text = TR("Bluetooth name: ") + prefix.bleName
        prefixLbl.text = TR("OTA prefix: ") + prefix.prefix
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
