//
//  ModifyNameVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ModifyNameVC: BaseViewController {

    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var nNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = User.current.name
    }


    @IBAction func btnClick(_ sender: Any) {
        
        guard let name = nNameTF.text, name.count > 0 else {
            showError("请输入名称");
            return;
        }
        
        let params = ["name": name]
        
        startLoading(nil)
        NetworkManager.shared.post(API_USER_MODIFY_NAME, params: params, callback: { (resp) in
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
            user.name = "\(dict["name"] ?? "")"
            user.save()
            self.navigationController?.popViewController(animated: true)
            self.showSuccess("修改成功")
            
        })
        
    }
    

}
