//
//  ToolsObjCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/27.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol ToolsObjCellDelegate: NSObjectProtocol {
    func toolsDidClickMerge(cell: UITableViewCell);
}

class ToolsObjCell: UITableViewCell {
    
    weak var delegate: ToolsObjCellDelegate?

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(withToolsObj tools: ToolsObj) {
        nameLbl.text = tools.name
        usernameLbl.text = "作者：\(tools.userName)"
    }
    
    // MARK: - 事件处理
    
    @IBAction func mergeBtnClick(_ sender: Any) {
        delegate?.toolsDidClickMerge(cell: self)
    }
    
}
