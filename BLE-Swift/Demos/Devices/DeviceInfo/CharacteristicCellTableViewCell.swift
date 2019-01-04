//
//  CharacteristicCellTableViewCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol CharacteristicCellTableViewCellDelegate: NSObjectProtocol {
    func didClickSendBtn(cell: UITableViewCell)
}

class CharacteristicCellTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var propertiesLbl: UILabel!
    
    @IBOutlet weak var uuidLbl: UILabel!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    weak var delegate: CharacteristicCellTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        
    }
    
    // MARK: - 事件处理
    @IBAction func sendBtnClick(_ sender: Any) {
        delegate?.didClickSendBtn(cell: self)
    }
    
    
    func updateUI(withDeviceInfo deviceInfo: DeviceInfo) {
        if deviceInfo.properties.contains("Write") {
            sendBtn.isHidden = false
        } else {
            sendBtn.isHidden = true
        }
        
        nameLbl.text = deviceInfo.name
        propertiesLbl.text = TR("Properties:") + deviceInfo.properties
        uuidLbl.text = TR("UUID:") + deviceInfo.uuid
        
    }
    
    
}
