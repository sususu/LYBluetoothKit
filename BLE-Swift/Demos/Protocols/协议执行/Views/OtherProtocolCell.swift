//
//  OtherProtocolCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/28.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtherProtocolCell: UICollectionViewCell {

    
    @IBOutlet weak var nameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLbl.layer.cornerRadius = 3
        nameLbl.layer.masksToBounds = true
    }

    func update(withProtocol proto: Protocol, selected: Bool) {
        nameLbl.text = proto.name
        if selected {
            nameLbl.backgroundColor = kMainColor
        } else {
            nameLbl.backgroundColor = rgb(150, 150, 150)
        }
    }
    
}
