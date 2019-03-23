//
//  ModifyWatchIdVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ModifyWatchIdVC: BaseViewController {
    
    @IBOutlet weak var idTF: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        showConnectState()

        // Do any additional setup after loading the view.
    }


    @IBAction func getOldBtnClick(_ sender: Any) {
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getDeviceID(stringCallback:  { (idStr, err) in
            weakSelf?.stopLoading()
            if let error = err {
                weakSelf?.errorCome(error: error)
                return
            }
            
            weakSelf?.idTF.text = idStr
            
        })
        
    }
    
    @IBAction func xgBtnClick(_ sender: Any) {
        modify(pushBack: false)
    }
    
    @IBAction func xgbcBtnClick(_ sender: Any) {
        modify(pushBack: true)
    }
    
    func modify(pushBack: Bool) {
        
        guard let idStr = idTF.text else {
            showError("请输入ID")
            return
        }
        
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.setDeviceID(id: idStr, boolCallback: { (bool, err) in
            weakSelf?.stopLoading()
            if let error = err {
                weakSelf?.errorCome(error: error)
                return
            }
            
            weakSelf?.showSuccess("修改成功")
            if pushBack {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
            
        })
    }
    
    func errorCome(error: BLEError) {
        self.handleBleError(error: error)
    }

}
