//
//  LoginVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class LoginVC: BaseViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passwordTF: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "登录"
    }


    // MARK: - 事件处理
    
    @IBAction func loginBtnClick(_ sender: Any) {
        
    }
    
    @IBAction func registBtnClick(_ sender: Any) {
        
        let vc = RegisterVC()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
