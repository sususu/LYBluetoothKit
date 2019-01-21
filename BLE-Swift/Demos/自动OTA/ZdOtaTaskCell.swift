//
//  ZdOtaTaskCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/21.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ZdOtaTaskCell: UITableViewCell {
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func updateUI(withTask task: ZdOtaTask) {
        nameLbl.text = task.name
    }
    
}
