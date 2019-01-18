//
//  TestGroupCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/18.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TestGroupCell: UICollectionViewCell {

    var nameLbl: UILabel!
    var cView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cView.frame = self.bounds
        nameLbl.frame = self.bounds.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    func initViews() {
        nameLbl = UILabel()
        nameLbl.textColor = UIColor.white
        nameLbl.textAlignment = .center
        nameLbl.font = font(14)
        
        cView = UIView()
        cView.layer.cornerRadius = 5
        cView.backgroundColor = rgb(180, 180, 180)
        cView.layer.masksToBounds = true
        
        contentView.addSubview(cView)
        contentView.addSubview(nameLbl)
    }
    
    
    func updateUI(withGroup group: DeviceTestGroup) {
        nameLbl.text = group.name
    }
    
    func updateSelected(selected: Bool) {
        if selected {
            cView.backgroundColor = kMainColor
        } else {
            cView.backgroundColor = rgb(180, 180, 180)
        }
    }
}
