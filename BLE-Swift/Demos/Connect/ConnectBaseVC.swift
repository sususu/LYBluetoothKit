//
//  ConnectBaseVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ConnectBaseVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavLeftButton(withIcon: "lanya", sel: #selector(gotoBluetoothConnect));
    }
    
    @objc func gotoBluetoothConnect() {
        slideMenuController()?.toggleLeft()
    }
    
}
