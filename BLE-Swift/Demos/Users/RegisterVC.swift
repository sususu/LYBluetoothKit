//
//  RegisterVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import LYNetwork

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
        
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        let name = nameTF.text ?? ""
        
        if !email.isEmail() {
            showError("请输入正确的邮箱地址")
            return
        }
        
        if password.hasIllegalCharacters() || password.count < 6 || password.count > 20 {
            showError("请输入6-20位正确密码")
            return
        }
        
        if name.count == 0 {
            showError("请输入名称")
            return
        }
        
        let params = ["email": email, "password": password, "name": name]
        
        startLoading(nil)
        NetworkManager.shared.post(API_USER_REGISTER, params: params, callback: { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            
            self.showSuccess("注册成功")
        })
        
    }
    
}
