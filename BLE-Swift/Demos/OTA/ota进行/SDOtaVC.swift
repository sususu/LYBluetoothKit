//
//  SDOtaVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

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
    
    // MARK: - 业务逻辑
    func parseConfigAndUpdateUI() {
        
        nameLbl.text = config.deviceName
        
        for fm in config.firmwares {
            
            var f = true
            
            for dict in firmwaresArr {
                let type = dict[kTypeKey] as! OtaDataType
                if type == fm.type {
                    f = false
                }
                var arr = dict[kFirmwaresKey] as! Array<Firmware>;
                arr.append(fm)
            }
            
            if f {
                let name = TR("OTA LIST") + "(" + Firmware.getTypeName(withType: fm.type) + ")"
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
    }
    
    @IBAction func versionBtnClick(_ sender: Any) {
    }
    
    @IBAction func resetBtnClick(_ sender: Any) {
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
    
    func startOTA() {
        
        resetOtaUI()
        
        guard let device = BLECenter.shared.getConnectedDevice(withName: config.deviceName) else {
            stopLoading()
            showError(config.deviceName + TR("is disconnected, please reconnect"))
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
        if config.prefix.count == 0 || device.isApollo3 {
            otaBleName = device.name
        }
        
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
            BLEConfig.shared.mtu = 128;
        } else {
            BLEConfig.shared.mtu = 20;
        }
        
        weak var weakSelf = self
        otaNameLbl.text = otaBleName
        startLoading(nil)
        otaTask = OtaManager.shared.startOta(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: {
            weakSelf?.stopLoading()
        }, progressCallback: nil, finishCallback: nil)
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
        cell.textLabel?.font = font(12)
        cell.textLabel?.textColor = rgb(80, 80, 80)
        cell.textLabel?.text = arr[indexPath.row].name + "(\(arr[indexPath.row].versionName.count == 0 ? "--" : arr[indexPath.row].versionName))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return firmwaresArr[section][kNameKey] as? String
    }
}
