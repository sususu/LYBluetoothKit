//
//  ZdOtaFirmwaresVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/19.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import DLRadioButton

class ZdOtaFirmwaresVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, FirmwareSelectVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fmRadio: DLRadioButton!
    
    @IBOutlet weak var fmVersionTF: UITextField!
    
    
    @IBOutlet weak var picRadio: DLRadioButton!
    
    @IBOutlet weak var picVersionTF: UITextField!
    
    @IBOutlet weak var tpRadio: DLRadioButton!
    
    @IBOutlet weak var tpVersionTF: UITextField!
    
    @IBOutlet weak var hrRadio: DLRadioButton!
    
    @IBOutlet weak var hrVersionTF: UITextField!
    
    var config: OtaConfig!
    var firmwareStrs: [String] = ["", "", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = TR("升级固件信息")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "OtaDataSelectCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        setNavRightButton(text: TR("CONTINUE"), sel: #selector(continueBtnClick))

        fmRadio.otherButtons = [picRadio, tpRadio, hrRadio]
        fmRadio.isMultipleSelectionEnabled = true
        
        fmRadio.addTarget(self, action: #selector(radioChanged(radio:)), for: .touchUpInside)
        picRadio.addTarget(self, action: #selector(radioChanged(radio:)), for: .touchUpInside)
        tpRadio.addTarget(self, action: #selector(radioChanged(radio:)), for: .touchUpInside)
        hrRadio.addTarget(self, action: #selector(radioChanged(radio:)), for: .touchUpInside)
        
        radioChanged(radio: nil)
    }
    
    // 业务逻辑
    func updateUI() {
        
        firmwareStrs = ["", "", "", ""]
        
        // 设置固件配置信息
        for fm in config.firmwares {
            if fm.type == .picture {
                firmwareStrs[1] = firmwareStrs[1] + fm.name + "\n"
            } else {
                firmwareStrs[getRow(forType: fm.type)] = fm.name
            }
        }
        
        // 去掉最后一个换行
        if firmwareStrs[1].count > 0 {
            firmwareStrs[1] = String(firmwareStrs[1].prefix(firmwareStrs[1].count - 1))
        }
        
        tableView.reloadData()
        
    }

    // MARK: - 事件处理
    
    @objc func radioChanged(radio: DLRadioButton?) {
        fmVersionTF.isEnabled = fmRadio.isSelected
        picVersionTF.isEnabled = picRadio.isSelected
        tpVersionTF.isEnabled = tpRadio.isSelected
        hrVersionTF.isEnabled = hrRadio.isSelected
        
        if !fmRadio.isSelected {
            removeFirmwares(byType: .platform)
        }
        if !picRadio.isSelected {
            removeFirmwares(byType: .picture)
        }
        if !tpRadio.isSelected {
            removeFirmwares(byType: .touchPanel)
        }
        if !hrRadio.isSelected {
            removeFirmwares(byType: .heartRate)
        }
        
        tableView.reloadData()
    }
    
    @IBAction func continueBtnClick(_ sender: Any) {
        if config.firmwares.count == 0 {
            showError(TR("Please select firmwares"))
            return
        }
        
        if fmVersionTF.isEnabled {
            guard let version = fmVersionTF.text, version.count > 0 else {
                showError(TR("请输入固件版本号"))
                return
            }
            
        }
        
        if picVersionTF.isEnabled {
            guard let version = picVersionTF.text, version.count > 0 else {
                showError(TR("请输入字库版本号"))
                return
            }
        }
        
        if tpVersionTF.isEnabled {
            guard let version = tpVersionTF.text, version.count > 0 else {
                showError(TR("请输入触摸版本号"))
                return
            }
        }
        
        if hrVersionTF.isEnabled {
            guard let version = hrVersionTF.text, version.count > 0 else {
                showError(TR("请输入心率版本号"))
                return
            }
        }
        
    }
    
    // 代理
    func didSelectFirmware(firmware: Firmware?, selectType: OtaDataType) {
        // 先移除旧的
        removeFirmwares(byType: selectType)
        
        
        // 再添加新的
        if firmware != nil {
            config.firmwares.append(firmware!)
        }
        updateUI()
    }
    
    func didSelectFirmwares(firmwares: [Firmware]?, selectType: OtaDataType) {
        
    }
    
    private func removeFirmwares(byType type: OtaDataType) {
        config.firmwares.removeAll { (fm) -> Bool in
            return fm.type == type
        }
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fmRadio.selectedButtons().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! OtaDataSelectCell
        cell.updateUI(withStr: firmwareStrs[indexPath.row], type: getDataType(forIndexPath: indexPath))
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TR("Select your firmware for OTA")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = getDataType(forIndexPath: indexPath)
        selectFirmware(byType: type)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = getDataType(forIndexPath: indexPath)
        if type == .picture {
            let count = firmwareStrs[getRow(forType: type)].components(separatedBy: "\n").count
            if count <= 1 {
                return 60
            } else {
                return CGFloat(40 + 25 * (count - 1))
            }
        }
        return 60
    }
    
    func selectFirmware(byType type: OtaDataType) {
        let vc = FirmwareSelectVC()
        vc.selectType = type
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getDataType(forIndexPath indexPath: IndexPath) -> OtaDataType {
        if indexPath.row == 0 {
            return .platform
        }
        else if indexPath.row == 1 {
            return .picture
        }
        else if indexPath.row == 2 {
            return .touchPanel
        }
        else {
            return .heartRate
        }
    }
    
    func getRow(forType type: OtaDataType) -> Int {
        if type == .platform {
            return 0
        }
        else if type == .picture {
            return 1
        }
        else if type == .touchPanel {
            return 2
        }
        else {
            return 3
        }
    }
}
