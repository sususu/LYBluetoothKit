//
//  AddProtocolVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class AddProtocolVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = TR("添加协议")
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }


    // MARK: - 事件处理
    @objc func saveBtnClick() {
        
    }

}
