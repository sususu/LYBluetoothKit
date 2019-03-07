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
    var servicesLbl:UILabel!
    var characteristicsLbl:UILabel!
    var stateLbl:UILabel!
    
    var device:BLEDevice? {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = rgb(180, 180, 180).cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = UIColor.white
        
        nameLbl = UILabel(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: 40))
        nameLbl.font = bFont(16)
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 0
        contentView.addSubview(nameLbl)
        
        servicesLbl = UILabel(frame: CGRect(x: 10, y: nameLbl.bottom + 20, width: frame.width - 20, height: 20))
        servicesLbl.font = font(16)
        servicesLbl.textAlignment = .center
        servicesLbl.numberOfLines = 0
        servicesLbl.textColor = rgb(100, 100, 100)
        contentView.addSubview(servicesLbl)
        
        characteristicsLbl = UILabel(frame: CGRect(x: 10, y: servicesLbl.bottom + 10, width: frame.width - 20, height: 20))
        characteristicsLbl.font = font(15)
        characteristicsLbl.textAlignment = .center
        characteristicsLbl.numberOfLines = 0
        characteristicsLbl.textColor = rgb(100, 100, 100)
        contentView.addSubview(characteristicsLbl)
        
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
                stateLbl.text = TR("connected")
                stateLbl.textColor = UIColor.green
            case .disconnected:
                stateLbl.text = TR("disconnected")
                stateLbl.textColor = UIColor.red
            case .ready:
                stateLbl.text = TR("connected")
                stateLbl.textColor = UIColor.green
            }
            servicesLbl.text = "\(device!.discoveredServices.count) 个服务"
            characteristicsLbl.text = "\(device!.characteristics.count) 个特征"
        }
    }
}
