//
//  PrefixAddVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/14.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol PrefixAddVCDelegate: NSObjectProtocol {
    func didSavePrefix(prefix: OtaPrefix)
}

class PrefixAddVC: BaseViewController {

    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var bleNamePrefixTF: UITextField!
    
    @IBOutlet weak var otaPrefixTF: UITextField!
    
    weak var delegate: PrefixAddVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TR("Add OTA Prefix")
        
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
        
        
    }

    
    @objc func saveBtnClick() {
        
        guard let deviceName = nameTF.text, deviceName.count > 0 else {
            showError(TR("Please input device name"))
            return
        }
        
        guard let bleName = bleNamePrefixTF.text, bleName.count > 0 else {
            showError(TR("Please input bluetooth name"))
            return
        }
        
        guard let otaPrefix = otaPrefixTF.text, otaPrefix.count > 0 else {
            showError(TR("Please input OTA prefix name"))
            return
        }
        
        let pf = OtaPrefix(deviceName: deviceName, bleName: bleName, prefix: otaPrefix)
        OtaService.shared.prefixs.insert(pf, at: 0)
        OtaService.shared.savePrefixsToDisk()
        delegate?.didSavePrefix(prefix: pf)
        showSuccess(TR("Success"))
    }
    
}
