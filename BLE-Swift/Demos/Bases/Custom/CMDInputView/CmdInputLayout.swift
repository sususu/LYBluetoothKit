//
//  CmdInputLayout.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/16.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class CmdInputLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayout()
    }
    
    func initLayout() {
        self.scrollDirection = .vertical
        self.minimumLineSpacing = 3
        self.minimumInteritemSpacing = 3
        self.sectionInset = UIEdgeInsets.zero
    }
}
