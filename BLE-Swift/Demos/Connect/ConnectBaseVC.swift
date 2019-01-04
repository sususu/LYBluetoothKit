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
        
        NotificationCenter.default.addObserver(self, selector: #selector(editDeviceNotification), name: kEditDeviceNotification, object: nil)
        
    }
    
    @objc func gotoBluetoothConnect() {
        slideMenuController()?.toggleLeft()
    }
    
    @objc func editDeviceNotification(notification: Notification) {
//        let device = notification.userInfo?["device"] as! BLEDevice
//        
//        let vc = DeviceInfoViewController(device: device)
//        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
