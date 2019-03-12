//
//  AddDeviceCircleGroupVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol AddDeviceCircleGroupVCDelegate: NSObjectProtocol {
    func didAddCircleGroup(_ testGroup: CircleGroup)
}

class AddDeviceCircleGroupVC: BaseViewController {

    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var numberInputView: NumberInputView!
    
    weak var delegate: AddDeviceCircleGroupVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加循环组"
        
        numberInputView.textField.text = "1"

        setNavRightButton(text: "保存", sel: #selector(saveCircleGroupClick))
    }


    // MARK: - 事件处理
    @objc func saveCircleGroupClick() {
        guard let name = nameTF.text else {
            showError("请输入名称")
            return
        }
        
        guard let numStr = numberInputView.textField.text else {
            showError("请输入重复次数")
            return
        }
        
        let cg = CircleGroup()
        cg.name = name
        cg.repeatCount = Int(numStr) ?? 1
        delegate?.didAddCircleGroup(cg)
        navigationController?.popViewController(animated: true)
    }
    
    
}
