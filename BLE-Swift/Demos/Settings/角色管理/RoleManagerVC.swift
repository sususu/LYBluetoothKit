//
//  RoleManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import DLRadioButton

class RoleManagerVC: BaseViewController {

    @IBOutlet weak var devRadio: DLRadioButton!
    
    @IBOutlet weak var testRadio: DLRadioButton!
    
    @IBOutlet weak var apollo3MTU: UITextField!
    
    @IBOutlet weak var otherMTU: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        devRadio.otherButtons = [testRadio]
        
        if AppConfig.current.roleType == .developer {
            devRadio.isSelected = true
        } else {
            testRadio.isSelected = true
        }
        
        apollo3MTU.text = "\(AppConfig.current.mtuForApollo3)"
        otherMTU.text = "\(AppConfig.current.mtu)"
        
        setNavRightButton(text: "保存", sel: #selector(saveBtnClick))
    }


    @objc func saveBtnClick() {
        
        guard let mtu3 = Int(apollo3MTU.text ?? ""), mtu3 >= 20 else {
            showError("请输入Apollo3正确的MTU");
            return
        }
        
        guard let mtu = Int(otherMTU.text ?? ""), mtu >= 20 else {
            showError("请输入其他正确的MTU");
            return
        }
        AppConfig.current.mtuForApollo3 = mtu3
        AppConfig.current.mtu = mtu
        
        if devRadio.isSelected {
            AppConfig.current.roleType = .developer
        } else {
            AppConfig.current.roleType = .tester
        }
        AppConfig.current.save()
        showSuccess("保存成功")
        
        navigationController?.popViewController(animated: true)
    }
    
}
