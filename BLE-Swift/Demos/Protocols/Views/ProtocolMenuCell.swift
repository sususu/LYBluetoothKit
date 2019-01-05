//
//  ProtocolMenuCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenuCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(withMenu menu:ProtocolMenu) {
        nameLbl.text = menu.name
    }
}
