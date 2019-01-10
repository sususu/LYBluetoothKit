//
//  OtaViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaViewController: ConnectBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    // MARK: - 事件处理
    @IBAction func autoOtaBtnClick
() {
        
    }

    @IBAction func sdBtnClick() {
        let vc = OtaConfigVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func oneKeyOtaBtnClick() {
        
    }
}
