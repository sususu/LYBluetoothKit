//
//  AddDeviceCircleTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol AddDeviceCircleTestVCDelegate: NSObjectProtocol {
    func didAddDeviceCT(ct: CircleTest)
}

class AddDeviceCircleTestVC: UIViewController {
    
    var delegate: AddDeviceCircleTestVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
