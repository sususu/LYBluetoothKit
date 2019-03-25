//
//  SportDetailCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SportDetailCell: UITableViewCell {

    @IBOutlet weak var indexLbl: UILabel!
    
    @IBOutlet weak var stepLbl: UILabel!
    
    @IBOutlet weak var calLbl: UILabel!
    
    @IBOutlet weak var disLbl: UILabel!
    
    @IBOutlet weak var duLbl: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var bpmLbl: UILabel!
    
    @IBOutlet weak var typeLbl: UILabel!
    
    
    func updateUI(withSport sport: Sport) {
        indexLbl.text = "索引：\(sport.index)"
        stepLbl.text = "步数：\(sport.step)"
        calLbl.text = "卡路里：\(sport.calorie)"
        disLbl.text = "距离：\(sport.distance)"
        duLbl.text = "时长：\(sport.duration)"
        
        timeLbl.text = "时间：" + String.timeString(fromTimeInterval: sport.time)
        bpmLbl.text = "心率：\(sport.avgBpm)"
        
        let types: [String] = ["unknown", "walk", "run", "situp", "swin", "ride", "climb stairs", "climb mountain", "stand", "sit"]
        typeLbl.text = "类型：" + types[sport.type.rawValue]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
