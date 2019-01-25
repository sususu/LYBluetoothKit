//
//  ZdOtaDisplayVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/21.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ZdOtaDisplayVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    var config: OtaConfig!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logTV: UITextView!
    
    var taskList = [ZdOtaTask]()
    
    var successList = [ZdOtaTask]()
    var failedList = [ZdOtaTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "自动OTA"
        self.view.backgroundColor = UIColor.black
        
        logTV.layoutManager.allowsNonContiguousLayout = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ZdOtaTaskCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.allowsSelection = false

        setNavLeftButton(text: "回到主页", sel: #selector(gotoHome))
        setNavRightButton(text: "查看配置", sel: #selector(gotoConfig))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaTaskFailed(notification:)), name: kZdOtaTaskFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otaTaskSuccess(notification:)), name: kZdOtaTaskSuccess, object: nil)
        
        startScan()
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
    // 扫描
    private var scanDevices: [BLEDevice]?
    func startScan() {
        printLog("开始扫描设备")
        weak var weakSelf = self
        BLECenter.shared.scan(callback: { (devices, err) in
            weakSelf?.scanDevices = devices
        }, stop: {
            weakSelf?.startConnect()
        }, after: 5)
    }

    // 开始连接设备
    func startConnect() {
        
        let count = getOtaingCount()
        if count >= config.upgradeCountMax {
            printLog("当前正在进行ota的个数(\(count))，已经最大了")
            return
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.startScan()
            }
        }
        
        guard let devices = scanDevices, devices.count > 0 else {
            printLog("扫描到设备个数为0")
            return
        }
        printLog("开始挑选满足条件的，并连接设备")
        for d in devices {
            
            if getOtaingCount() >= config.upgradeCountMax {
                return
            }
            
            if !isDeviceAvaiable(name: d.name) {
                continue
            }
            
            if d.name.hasPrefix(config.deviceNamePrefix), d.rssi >= config.signalMin {
                let task = ZdOtaTask(name: d.name, config: config)
                taskList.append(task)
                weak var weakSelf = self
                BLECenter.shared.connect(device: d, callback: { (device, err) in
                    
                    // 如果有错误，那处理错误
                    if err != nil {
                        let msg = weakSelf?.errorMsgFromBleError(err)
                        weakSelf?.printLog("连接(\(d.name))出错：\(msg ?? "")")
                        weakSelf?.removeOtaTask(byName: d.name)
                        return
                    }
                    
                    // 如果成功，那就进行到下一步
                    weakSelf?.deviceConnected(device: device!)
                    
                }, timeout: 10)
            }
        }
    }
    
    func deviceConnected(device: BLEDevice) {
        guard let task = getOtaTask(byName: device.name) else {
            return
        }
        
        printLog("开始OTA(\(device.name))")
        task.startOTA(withDevice: device)
        
        tableView.reloadData()
    }
    
    
    private func getOtaingCount() -> Int {
        var count = 0
        for task in taskList {
            if task.state == .start || task.state == .plain {
                count += 1
            }
        }
        return count
    }
    
    private func isDeviceAvaiable(name: String) -> Bool {
        for task in successList {
            if task.name == name {
                return false
            }
        }
        
        for task in taskList {
            if task.name == name {
                return false
            }
        }
        
        for task in failedList {
            if task.name == name {
                return false
            }
        }
        
        return true
    }
    
    private func getOtaTask(byName name: String) -> ZdOtaTask? {
        for task in taskList {
            if task.name == name {
                return task
            }
        }
        return nil
    }
    
    private func removeOtaTask(byName name: String) {
        for i in 0 ..< taskList.count {
            let task = taskList[i]
            if task.name == name {
                taskList.remove(at: i)
                return
            }
        }
    }

    // MARK: - 事件处理
    @IBAction func stopBtnClick(_ sender: Any) {
        
    }
    
    @IBAction func cktjBtnClick(_ sender: Any) {
        let vc = ZdOtaResultVC()
        vc.failList = failedList
        vc.successList = successList
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func gotoHome() {
       
        let alert = UIAlertController(title: "温馨提醒", message: "如果返回首页，会停止当前所有正在进行的任务，您确定要返回吗？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "返回", style: .default) { (action) in
            OtaManager.shared.cancelAllTask()
        self.navigationController?.setViewControllers([self.navigationController!.viewControllers[0]], animated: true)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func gotoConfig() {
        
    }
    
    // MARK: - 通知
    @objc func otaTaskFailed(notification: Notification) {
        guard let dict = notification.userInfo as? Dictionary<String, Any> else {
            return
        }
        guard let task = dict["task"] as? ZdOtaTask else {
            return
        }
        failedList.append(task)
        removeOtaTask(byName: task.name)
        checkCountAndAlert()
        
        tableView.reloadData()
    }
    
    @objc func otaTaskSuccess(notification: Notification) {
        guard let dict = notification.userInfo as? Dictionary<String, Any> else {
            return
        }
        guard let task = dict["task"] as? ZdOtaTask else {
            return
        }
        successList.append(task)
        removeOtaTask(byName: task.name)
        checkCountAndAlert()
        
        tableView.reloadData()
    }
    
    func checkCountAndAlert() {
        if successList.count + failedList.count >= config.otaCount
        {
            // 增加停止ota代码
            
            VoiceSpeaker.shared.speak(text: "您好，您的 O T A 升级任务已完成", shouldLoop: true)
            let alert = UIAlertController(title: "温馨提醒", message: "您的OTA升级任务已完成", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel) { (action) in
                VoiceSpeaker.shared.stopSpeaking()
                
                let vc = ZdOtaResultVC()
                vc.failList = self.failedList
                vc.successList = self.successList
                self.navigationController?.pushViewController(vc, animated: true)
            }
            alert.addAction(ok)
            navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "OTA列表"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ZdOtaTaskCell
        cell.updateUI(withTask: taskList[indexPath.row])
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    } 
    
    
    // 日志
    private var logStr = ""
    private var logLine = 1
    private func printLog(_ log: String) {
        logStr += "\(logLine). " + log + "\n"
        logTV.text = logStr
        logLine += 1
        logTV.scrollRangeToVisible(NSMakeRange(logStr.count - 1, 1))
    }
}
