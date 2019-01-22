//
//  RegisterVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class RegisterVC: BaseViewController {

    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "注册"
    }

    
    
    // MARK: - 事件处理
    
    @IBAction func registBtnClick(_ sender: Any) {
    }
    
}
