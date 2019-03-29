//
//  SDOtaVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import SSZipArchive

class SDOtaVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    let kNameKey = "kNameKey"
    let kTypeKey = "kTypeKey"
    let kFirmwaresKey = "kFirmwaresKey"

    var config: OtaConfig!
    var firmwaresArr : [Dictionary<String, Any>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var startStopBtn: UIButton!
    
    @IBOutlet weak var progressLbl: UILabel!
    
    @IBOutlet weak var otaNameLbl: UILabel!
    var otaTask: OtaTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showConnectState()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
    
        startStopBtn.layer.cornerRadius = 40
        startStopBtn.layer.masksToBounds = true
        startStopBtn.setTitleColor(rgb(200, 30, 30), for: .selected)
        startStopBtn.setTitle(TR("STOP"), for: .selected)
        startStopBtn.setTitle(TR("START"), for: .normal)
        
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
        progressView.progress = 0.0
        
        setNavRightButton(text: TR("HOME"), sel: #selector(backToHome))
        
        parseConfigAndUpdateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaFailedNotification(notification:)), name: kOtaTaskFailedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otaFinishNotification(notification:)), name: kOtaTaskFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otaProgressNotification(notification:)), name: kOtaTaskProgressUpdateNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - 业务逻辑
    // 解析ota配置模型 OtaConfig
    func parseConfigAndUpdateUI() {
        
        nameLbl.text = config.deviceName
        
        for fm in config.firmwares {
            
            var f = true
            
            for i in 0 ..< firmwaresArr.count {
                var dict = firmwaresArr[i]
                let type = dict[kTypeKey] as! OtaDataType
                if type == fm.type {
                    f = false
                    
                    var arr = dict[kFirmwaresKey] as! Array<Firmware>;
                    arr.append(fm)
                    dict[kFirmwaresKey] = arr
                    firmwaresArr[i] = dict
                }
            }

            if f {
                let name = Firmware.getTypeName(withType: fm.type)
                var arr = [Firmware]();
                arr.append(fm)
                
                var dict = Dictionary<String, Any>()
                dict[kNameKey] = name
                dict[kTypeKey] = fm.type
                dict[kFirmwaresKey] = arr
                
                firmwaresArr.append(dict)
            }
        }
        
        tableView.reloadData()
        
    }
    

    // MARK: - 事件处理
    @IBAction func deviceIdBtnClick(_ sender: Any) {
        
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getDeviceID(stringCallback: { (str, err) in
            weakSelf?.stopLoading()
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showAlert(title: TR("DEVICE ID"), message: str ?? "")
            }
            
        }, toDeviceName: config.deviceName)
        
    }
    
    @IBAction func versionBtnClick(_ sender: Any) {
        let sheet = UIAlertController(title: TR("CHOOSE TYPE"), message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: TR("WITH BUILD"), style: .default) { (action) in
            self.getFirmwareVersion(type: 5)
        }
        let action2 = UIAlertAction(title: TR("NO BUILD"), style: .default) { (action) in
            self.getFirmwareVersion(type: 1)
        }
        let action3 = UIAlertAction(title: TR("DATE FORMAT"), style: .default) { (action) in
            self.getFirmwareVersion(type: 6)
        }
        let action4 = UIAlertAction(title: TR("CANCEL"), style: .destructive)
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(action3)
        sheet.addAction(action4)
        navigationController?.present(sheet, animated: true, completion: nil)
    }
    
    func getFirmwareVersion(type: UInt8) {
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getVersionStr(forType: type, stringCallback: { (str, err) in
            weakSelf?.stopLoading()
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showAlert(title: "固件版本号", message: str ?? "")
            }
            
        }, toDeviceName: config.deviceName)
    }
    
    
    
    @IBAction func resetBtnClick(_ sender: Any) {
        
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.resetDevice(boolCallback: { (b, err) in
            weakSelf?.stopLoading()
            
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showSuccess(TR("Success"))
            }
            
        }, toDeviceName: config.deviceName)
    }
    
    @IBAction func startOrStopBtnClick(_ sender: Any) {
        if startStopBtn.isSelected {
            startStopBtn.isSelected = false
            stopOTA()
        } else {
            startStopBtn.isSelected = true
            startOTA()
        }
    }
    
    // MARK: - 业务逻辑
    func stopOTA() {
        guard let task = self.otaTask else {
            stopLoading()
            return
        }
        startLoading(nil)
        OtaManager.shared.cancelTask(task)
    }
    
    // MARK: - 开始ota
    func startOTA() {
        
        resetOtaUI()
        
        guard let device = BLECenter.shared.getConnectedDevice(withName: config.deviceName) else {
            stopLoading()
            showError(config.deviceName + " " + TR("is disconnected, please reconnect"))
            self.startStopBtn.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1                                                                             ) {
                self.startStopBtn.isEnabled = true
                self.startStopBtn.isSelected = false
            }
            
            return
        }
        
        if config.deviceName.count < 5 {
            showError(TR("Device'name is unsupported, please contact with administrator"))
            stopLoading()
            startStopBtn.isSelected = false
            return
        }
        
        var otaBleName = config.prefix + config.deviceName.suffix(5)
        if config.prefix.count == 0 || device.isApollo3 || config.platform == .tlsr {
            otaBleName = device.name
        }
        
        switch config.platform {
        case .apollo:
            startApolloOTA(device: device, otaBleName: otaBleName)
        case .nordic:
            startNordicOTA(device: device, otaBleName: otaBleName)
        case .tlsr:
            startTlsrOTA(device: device, otaBleName: otaBleName)
        }
        
    }
    
    // MARK: - 开始Apollo OTA
    func startApolloOTA(device: BLEDevice, otaBleName: String) {
        var otaDatas = [OtaDataModel]()
        for fm in config.firmwares {
            
            let path = StorageUtils.getDocPath().stringByAppending(pathComponent: fm.path)
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let dm = OtaDataModel(type: fm.type, data: data)
                otaDatas.append(dm)
            }
            catch {}
        }
        
        if otaDatas.count == 0 {
            showError(TR("OtaDatas parse failed"))
            stopLoading()
            startStopBtn.isSelected = false
            return
        }
        
        if device.isApollo3 {
            BLEConfig.shared.mtu = 128
        } else {
            BLEConfig.shared.mtu = 20
        }
        
        weak var weakSelf = self
        otaNameLbl.text = otaBleName
        startLoading(nil)
        otaTask = OtaManager.shared.startOta(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: {
            weakSelf?.stopLoading()
        }, progressCallback: nil, finishCallback: nil)
        otaTask?.config = config
    }
    
    // MARK: - 开始Nordic OTA
    func startNordicOTA(device: BLEDevice, otaBleName: String) {
        var otaDatas = [OtaDataModel]()
        for fm in config.firmwares {
            
            let path = StorageUtils.getDocPath().stringByAppending(pathComponent: fm.path)
            
            // 如果是平台升级
            if fm.type == .platform {
                let cachePath = StorageUtils.getCahcePath()
                let unzipPath = cachePath.stringByAppending(pathComponent: "ota")
                StorageUtils.deleteFiles(atPath: unzipPath)
                
                if SSZipArchive.unzipFile(atPath: path, toDestination: unzipPath) {
                    let manager = FileManager.default
                    do {
                        let fileNames = try manager.contentsOfDirectory(atPath: unzipPath)
                        for name in fileNames {
                            var tmpPath = unzipPath.stringByAppending(pathComponent: name)
                            // 先找到bin
                            if name.hasSuffix(".bin") {
                                let data = try Data(contentsOf: URL(fileURLWithPath: tmpPath))
                                let dm = OtaDataModel(type: fm.type, data: data)
                                // 再找dat
                                for name in fileNames {
                                    tmpPath = unzipPath.stringByAppending(pathComponent: name)
                                    if name.hasSuffix(".dat") {
                                        let datData = try Data(contentsOf: URL(fileURLWithPath: tmpPath))
                                        dm.datData = datData
                                    }
                                }
                                otaDatas.append(dm)
                                break
                            }
                        }
                    } catch {}
                }
                else {
                    print("解压失败")
                }
            }
            // 否则是其他升级
            else {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    let dm = OtaDataModel(type: fm.type, data: data)
                    otaDatas.append(dm)
                }
                catch {}
            }
        }
        
        if otaDatas.count == 0 {
            showError(TR("OtaDatas parse failed"))
            stopLoading()
            startStopBtn.isSelected = false
            return
        }
        
        BLEConfig.shared.mtu = 20
    
        weak var weakSelf = self
        otaNameLbl.text = otaBleName
        startLoading(nil)
        otaTask = OtaManager.shared.startNordicOta(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: {
        weakSelf?.stopLoading()
        }, progressCallback: nil, finishCallback: nil)
        otaTask?.config = config
    }
    
    // MARK: - 开始泰心OTA
    func startTlsrOTA(device: BLEDevice, otaBleName: String) {
        var otaDatas = [OtaDataModel]()
        for fm in config.firmwares {
            
            let path = StorageUtils.getDocPath().stringByAppending(pathComponent: fm.path)
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let dm = OtaDataModel(type: fm.type, data: data)
                otaDatas.append(dm)
            }
            catch {}
        }
        
        if otaDatas.count == 0 {
            showError(TR("OtaDatas parse failed"))
            stopLoading()
            startStopBtn.isSelected = false
            return
        }
        
        BLEConfig.shared.mtu = 20
        
        weak var weakSelf = self
        otaNameLbl.text = otaBleName
        startLoading(nil)
        otaTask = OtaManager.shared.startTlsrOta(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: {
            weakSelf?.stopLoading()
        }, progressCallback: nil, finishCallback: nil)
        otaTask?.config = config
    }
    
    @objc func backToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func otaFailedNotification(notification: Notification) {
        stopLoading()
        if let err = notification.userInfo?["error"] as? BLEError {
            let errorMsg = errorMsgFromBleError(err)
            showError(errorMsg)
            progressView.progress = 1
            progressView.progressTintColor = rgb(200, 30, 30)
            progressLbl.textColor = rgb(200, 30, 30)
            progressLbl.text = errorMsg
            startStopBtn.isSelected = false
        }
    }
    @objc func otaFinishNotification(notification: Notification) {
        stopLoading()
        showSuccess(TR("OTA success"))
        progressView.progress = 1
        progressView.progressTintColor = rgb(30, 200, 30)
        progressLbl.textColor = rgb(30, 200, 30)
        progressLbl.text = TR("OTA success")
        startStopBtn.isSelected = false
    }
    @objc func otaProgressNotification(notification: Notification) {
        guard let task = notification.userInfo?[BLEKey.task] as? OtaTask else {
            return
        }
        progressView.progress = task.progress
        progressLbl.text = "\(Int(task.progress * 100))%"
    }
    
    func resetOtaUI() {
        progressView.progress = 0
        progressView.progressTintColor = kMainColor
        progressLbl.text = "0%"
        progressLbl.textColor = kMainColor
        otaNameLbl.text = ""
    }
    
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return firmwaresArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = firmwaresArr[section][kFirmwaresKey] as! Array<Firmware>
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arr = firmwaresArr[indexPath.section][kFirmwaresKey] as! Array<Firmware>
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(16)
        cell.textLabel?.textColor = rgb(80, 80, 80)
        cell.textLabel?.text = arr[indexPath.row].name + "(\(arr[indexPath.row].versionName.count == 0 ? "--" : arr[indexPath.row].versionName))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return firmwaresArr[section][kNameKey] as? String
    }
    
    
    // MARK: - 工具
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: TR("OK"), style: .cancel, handler: nil)
        let csAction = UIAlertAction(title: TR("COPY"), style: .destructive) { (action) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = message
        }
        alert.addAction(okAction)
        alert.addAction(csAction)
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
