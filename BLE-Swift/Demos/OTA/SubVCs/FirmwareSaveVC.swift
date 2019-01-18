//
//  FirmwareSaveVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class FirmwareSaveVC: BaseViewController, FirmwareTypeVCDelegate {

    var tmpFirmware: Firmware!
    
    var service = OtaService.shared
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var versionTF: UITextField!
    @IBOutlet weak var typeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = TR("Firmware")
        
        setNavLeftButton(withIcon: "fanhui", sel: #selector(cancelBtnClick))
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
        
        updateUI()
    }
    
    func updateUI() {
        nameTF.text = tmpFirmware.name
        versionTF.text = tmpFirmware.versionName
        typeLbl.text = Firmware.getTypeName(withType: tmpFirmware.type)
    }


    @IBAction func selectTypeBtnClick(_ sender: Any) {
        let vc = FirmwareTypeVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 事件处理
    @objc func cancelBtnClick() {
        let absolutePath = StorageUtils.getDocPath().stringByAppending(pathComponent: tmpFirmware.path)
        _ = StorageUtils.deleteFile(atPath: absolutePath)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveBtnClick() {
        if nameTF.text?.count == 0 {
            self.showError("Please input name")
            return
        }
        
        if versionTF.text?.count == 0 {
            self.showError(TR("Please input version"))
            return
        }
        
        self.view.endEditing(true)
        doSaveFirmware()
    }
    
    @objc func doSaveFirmware() {
        
        tmpFirmware.name = nameTF.text!
        tmpFirmware.versionName = versionTF.text!
        service.saveFirmware(tmpFirmware)
        
        showSuccess(TR("Cool"))
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    

    func didFinishSelectType(type: OtaDataType) {
        tmpFirmware.type = type
        updateUI()
    }
    
}
