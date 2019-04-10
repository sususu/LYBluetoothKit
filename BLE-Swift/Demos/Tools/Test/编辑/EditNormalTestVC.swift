//
//  EditNormalTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class EditNormalTestVC: BaseViewController, EditProtocolVCDelegate {

    var product: DeviceProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "编辑常规测试"
    }

    @IBAction func screenUpBtnClick(_ sender: Any) {
        if self.product.screenUpProto == nil {
            self.product.screenUpProto = Protocol()
        }
        
        let vc = EditProtocolVC()
        vc.proto = self.product.screenUpProto
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func initBtnClick(_ sender: Any) {
        let vc = ToolInitVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func syncTimeBtnClick(_ sender: Any) {
        if self.product.syncTimeProto == nil {
            self.product.syncTimeProto = Protocol()
        }
        
        let vc = EditProtocolVC()
        vc.proto = self.product.syncTimeProto
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func infoBtnClick(_ sender: Any) {
        let vc = WatchInfoEditVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func didAddNewProtocol(protocol: Protocol) {
        
    }
    
    func didEditNewProtocol(protocol: Protocol) {
        
    }

}
