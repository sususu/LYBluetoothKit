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
        
        emailTF.text = "sujiang@appscomm.cn";
        passwordTF.text = "qwerty";
    }


    // MARK: - 事件处理
    
    @IBAction func loginBtnClick(_ sender: Any) {
     
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        if !email.isEmail() {
            showError("请输入正确的邮箱地址")
            return
        }
        
        if password.hasIllegalCharacters() || password.count < 6 || password.count > 20 {
            showError("请输入6-20位正确密码")
            return
        }
        
        let params = ["email": email, "password": password]
        
        startLoading(nil)
        NetworkManager.shared.post(API_USER_LOGIN, params: params) { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            
            guard let dict = resp.data as? Dictionary<String, Any> else {
                self.showError("登录异常，返回数据为空")
                return
            }
            
            let user = User.current
            user.id = "\(dict["id"] ?? "")"
            user.name = "\(dict["name"] ?? "")"
            user.email = "\(dict["email"] ?? "")"
            user.jwt = "\(dict["jwt"] ?? "")"
            user.isadmin = (dict["isadmin"] as? Bool) ?? false
            user.save()
            self.navigationController?.popViewController(animated: true)
            self.showSuccess("登录成功")
        }
        
    }
    
    @IBAction func registBtnClick(_ sender: Any) {
        
        let vc = RegisterVC()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
