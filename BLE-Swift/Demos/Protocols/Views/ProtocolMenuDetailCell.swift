//
//  ProtocolMenuDetailCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenuDetailCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(withProtocol p:Protocol) {
        nameLbl.text = p.name
    }
}
