//
//  DevicesCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/16.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

let kDevicesCellId = "kDevicesCellId"
class DevicesCell: UICollectionViewCell {
    
    var nameLbl:UILabel!
    var stateLbl:UILabel!
    
    var device:BLEDevice? {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = rgb(100, 100, 100).cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = UIColor.white
        
        nameLbl = UILabel(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: 40))
        nameLbl.font = bFont(16)
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 0
        contentView.addSubview(nameLbl)
        
        stateLbl = UILabel(frame: CGRect(x: 0, y: frame.height - 20 - 20, width: frame.width, height: 20))
        stateLbl.font = font(14)
        stateLbl.textAlignment = .center
        contentView.addSubview(stateLbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateUI() {
        if device == nil {
            nameLbl.text = ""
            stateLbl.text = ""
        } else {
            nameLbl.text = device!.name
            switch device!.state {
            case .connected:
                stateLbl.text = "connected"
                stateLbl.textColor = UIColor.green
            case .disconnected:
                stateLbl.text = "disconnected"
                stateLbl.textColor = UIColor.red
            case .ready:
                stateLbl.text = "connected"
                stateLbl.textColor = UIColor.green
            }
        }
    }
}
