//
//  AddDeviceCircleGroupVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol AddDeviceCircleGroupVCDelegate: NSObjectProtocol {
    func didAddCircleGroup(_ testGroup: CircleGroup);
}

class AddDeviceCircleGroupVC: BaseViewController {

    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var numberInputView: NumberInputView!
    
    weak var delegate: AddDeviceCircleGroupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavRightButton(text: "保存", sel: #selector(saveCircleGroupClick))
    }


    // MARK: - 事件处理
    @objc func saveCircleGroupClick() {
        
    }
    
    
}
