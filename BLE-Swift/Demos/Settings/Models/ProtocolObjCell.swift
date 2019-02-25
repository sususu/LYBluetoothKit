//
//  ProtocolObjCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol ProtocolObjCellDelegate: NSObjectProtocol {
    func poDidClickMerge(cell: UITableViewCell);
}

class ProtocolObjCell: UITableViewCell {

    weak var delegate: ProtocolObjCellDelegate?
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUI(withProtocolObj po: ProtocolObj) {
        nameLbl.text = po.name
        usernameLbl.text = "作者：\(po.userName)"
    }
    @IBAction func mergeBtnClick(_ sender: Any) {
        delegate?.poDidClickMerge(cell: self)
    }
}
