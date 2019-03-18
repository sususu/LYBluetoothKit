//
//  OtaConfigVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kOtaConfigLastPrefixKey = "kOtaConfigLastPrefixKey"


class OtaConfigVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, FirmwareSelectVCDelegate, PrefixSelectVCDelegate {

    @IBOutlet weak var platformSeg: UISegmentedControl!
    @IBOutlet weak var prefixTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var firmwareStrs: [String] = ["", "", "", "", ""]
    var config = OtaConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showConnectState()
        // Do any additional setup after loading the view.
        prefixTextField.leftViewMode = .always
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: prefixTextField.bounds.height))
        lbl.text = TR("  OTA prefix: ")
        lbl.textColor = rgb(200, 30, 30)
        lbl.font = font(14)
        prefixTextField.leftView = lbl
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "OtaDataSelectCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 80
        
        setNavRightButton(text: TR("CONTINUE"), sel: #selector(continueBtnClick))
        
        
        // 头部配置信息
        platformSeg.selectedSegmentIndex = Int(config.platform.rawValue)
        prefixTextField.text = config.prefix
        
        if prefixTextField.text?.count == 0 {
            prefixTextField.text = StorageUtils.getString(forKey: kOtaConfigLastPrefixKey)
        }
        
        // 如果还没有连接任何设备，则进行连接
        if !BLECenter.shared.hasConnectedDevice {
            let vc = ConnectVC()
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // 业务逻辑
    func updateUI() {
        
        firmwareStrs = ["", "", "", "", ""]
        
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
    
    // MARK: - 业务逻辑

    // MARK: - 事件处理
    @IBAction func platformChangedAction(_ sender: Any) {
        config.platform = OtaPlatform(rawValue: platformSeg.selectedSegmentIndex)!
        tableView.reloadData()
    }
    
    @IBAction func prefixBtnClick(_ sender: Any) {
        let vc = PrefixSelectVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func continueBtnClick(_ sender: Any) {
        guard let device = BLECenter.shared.connectedDevice else {
            self.showError(TR("Please connect a device"))
            return
        }
        
        if device.isOTAing {
            self.showError("设备：\(device.name)，正在ota了，你可以返回首页进行查看进度。")
            return
        }
        
        
        if !device.isApollo3 && prefixTextField.text?.count == 0 && config.platform != .tlsr {
            showError(TR("The connected device is not kind of Apollo3, please input OTA prefix"))
            return
        }
        
        if config.firmwares.count == 0 {
            showError(TR("Please select firmwares"))
            return
        }
        
        config.prefix = prefixTextField.text ?? ""
        config.deviceName = device.name
        
        let vc = SDOtaVC()
        vc.config = config
        navigationController?.pushViewController(vc, animated: true)
        
        if prefixTextField.text != nil {
            StorageUtils.saveString(prefixTextField.text!, forKey: kOtaConfigLastPrefixKey)
        }
    }
    
    // MARK: - 代理
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
        removeFirmwares(byType: selectType)
        
        if let fms = firmwares, fms.count > 0 {
            for fm in fms {
                config.firmwares.append(fm)
            }
        }
        updateUI()
    }
    
    private func removeFirmwares(byType type: OtaDataType) {
        config.firmwares.removeAll { (fm) -> Bool in
            return fm.type == type
        }
    }
    
    func didSelectPrefixStr(prefixStr: String, bleName: String) {
        prefixTextField.text = prefixStr
    }
    
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
        else if indexPath.row == 3 {
            return .heartRate
        }
        else {
            if platformSeg.selectedSegmentIndex == 0 {
                return .agps
            } else {
                return .freeScale
            }
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
        else if type == .heartRate {
            return 3
        } else {
            return 4
        }
    }
    
}
