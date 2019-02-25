//
//  ModifyPwdVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ModifyPwdVC: BaseViewController {
    
    @IBOutlet weak var oldPwdTf: UITextField!
    
    @IBOutlet weak var newPwdTf: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    @IBAction func saveBtnClick(_ sender: Any) {
        
        let oldPwd = oldPwdTf.text ?? ""
        let newPwd = newPwdTf.text ?? ""
        
        if oldPwd.hasIllegalCharacters() || oldPwd.count < 6 || oldPwd.count > 20 {
            showError("旧密码：请输入6-20位正确密码")
            return
        }
        
        if newPwd.hasIllegalCharacters() || newPwd.count < 6 || newPwd.count > 20 {
            showError("新密码：请输入6-20位正确密码")
            return
        }
        
        let params = ["oldPassword": oldPwd, "newPassword": newPwd]
        
        startLoading(nil)
        NetworkManager.shared.post(API_USER_MODIFY_PASSWORD, params: params, callback:{ (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            
            let user = User.current
            user.password = newPwd
            user.save()
            self.navigationController?.popViewController(animated: true)
            self.showSuccess("修改成功")
            
        })
        
    }
    

}
