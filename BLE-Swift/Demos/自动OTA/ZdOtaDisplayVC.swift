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
    var failedRecordList: Dictionary<String, Int> = [String : Int]()
    var unusedList = [ZdOtaTask]()
    
    var isStop: Bool = false
    var isConnecting: Bool = false
    var connectingName: String = ""
    var isScanning: Bool = false
    
    deinit {
        print("ZdOtaDisplayVC dealloc")
    }
    
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
        setNavRightButton(text: "查看结果", sel: #selector(gotoConfig))
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaTaskReady(notification:)), name: kZdOtaTaskReady, object: nil)
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
        cleanLog()
    }
    
    // MARK: - 业务逻辑
    // 扫描
    private var scanDevices: [BLEDevice]?
    func startScan() {
        
        if isStop {
            return
        }
        
        printLog("开始扫描设备")
        self.isScanning = true
        weak var weakSelf = self
        BLECenter.shared.scan(callback: { (devices, err) in
            weakSelf?.scanDevices = devices
        }, stop: {
            weakSelf?.isScanning = false
            weakSelf?.startConnect()
        }, after: 5)
    }

    // 开始连接设备
    func startConnect() {
        
        printLog("开始筛选设备，进行连接")
        
        // 如果已经停止了
        if isStop {
            return
        }
        
        // 如果正在连接
        if isConnecting {
            printLog("正在连接设备，不往下走了")
            return
        }
        
        
        let count = getOtaingCount()
        if count >= config.upgradeCountMax {
            printLog("当前正在进行ota的个数(\(count))，已经最大了")
            return
        }
//        else
//        {
//            printLog("15秒后，重新搜索")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
//                self.startScan()
//            }
//        }
        
        guard let devices = scanDevices, devices.count > 0 else {
            printLog("扫描到设备个数为0，5秒之后重新扫描")
            reScan(afterSecond: 5)
            return
        }
        printLog("开始挑选满足条件的，并连接设备")
        // 本次扫描是否有合适的设备
        var hasFitOne = false
        for d in devices {
            
            if !isDeviceAvaiable(name: d.name) {
                continue
            }
            
            if d.name.hasPrefix(config.deviceNamePrefix), d.rssi >= config.signalMin {
                hasFitOne = true
                // 只有ota准备好之后，这个值才会变成false
                // 在通知 otaTaskReady 处理方法里面
                self.isConnecting = true
                self.connectingName = d.name
                weak var weakSelf = self
                BLECenter.shared.connect(device: d, callback: { (device, err) in
                    
                    // 如果有错误，那处理错误
                    if err != nil {
                        let msg = weakSelf?.errorMsgFromBleError(err)
                        weakSelf?.printLog("连接(\(d.name))出错：\(msg ?? "")")
                        weakSelf?.removeOtaTask(byName: d.name)
                        weakSelf?.isConnecting = false
                        weakSelf?.reScan(afterSecond: 5)
                        return
                    }
                    // 如果成功，那就进行到下一步
                    weakSelf?.deviceConnected(device: device!)
                    
                }, timeout: 10)
                // 一次只连接一个
                break
            }
        }
        
        // 如果没有合适的，那5秒之后再重新扫描
        if !hasFitOne {
            printLog("扫描到合适的设备个数为0，5秒之后重新扫描")
            reScan(afterSecond: 5)
        }
        
        
    }
    
    func reScan(afterSecond second: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + second) {
            self.startScan()
        }
    }
    
    
    func deviceConnected(device: BLEDevice) {
        
        if isStop {
            isConnecting = false
            return
        }
        
        let task = ZdOtaTask(name: device.name, config: config)
        taskList.append(task)
        
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
        
        for task in unusedList {
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
    @IBAction func stopBtnClick(_ sender: Any?) {
        isStop = true
        taskList.removeAll()
        OtaManager.shared.cancelAllTask()
        tableView.reloadData()
    }
    
    @IBAction func cktjBtnClick(_ sender: Any) {
        let vc = ZdOtaResultVC()
        vc.failList = unusedList
        vc.successList = successList
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func gotoHome() {
       
        weak var weakSelf = self
        let alert = UIAlertController(title: "温馨提醒", message: "如果返回首页，会停止当前所有正在进行的任务，您确定要返回吗？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "返回", style: .default) { (action) in
            weakSelf?.isStop = true
            OtaManager.shared.cancelAllTask()
        self.navigationController?.setViewControllers([self.navigationController!.viewControllers[0]], animated: true)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func gotoConfig() {
        let vc = ZdOtaResultVC()
        vc.failList = unusedList
        vc.successList = successList
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 通知
    @objc func otaTaskReady(notification: Notification) {
        printLog("设备\(connectingName)准备ota成功，2秒之后，重新扫描连接其他设备")
        self.isConnecting = false
        reScan(afterSecond: 2)
    }
    
    @objc func otaTaskFailed(notification: Notification) {
        guard let dict = notification.userInfo as? Dictionary<String, Any> else {
            return
        }
        guard let task = dict["task"] as? ZdOtaTask else {
            return
        }
        
        
        // 如果是准备失败的，那isConnecting也会复位成 false
        if task.name == connectingName && isConnecting {
            printLog("准备ota失败，2秒之后重新扫描")
//            reScan(afterSecond: 2)
            isConnecting = false
//            return
        }
        
        if failedRecordList.keys.contains(task.name)
        {
            let count = (failedRecordList[task.name] ?? 1) + 1
            failedRecordList[task.name] = count
            if count >= kZdOtaTaskMaxTryCount {
                unusedList.append(task)
//                if checkCountAndAlert() {
//                    return
//                }
            }
        }
        else
        {
            task.tryCount = 1
            failedList.append(task)
            failedRecordList[task.name] = 1
        }
        removeOtaTask(byName: task.name)
        tableView.reloadData()
        printLog("2秒后重新扫描")
        reScan(afterSecond: 2)
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
        if !checkCountAndAlert() {
            printLog("设备：\(task.name) OTA成功，2秒后搜索连接ota下一个设备")
            reScan(afterSecond: 2)
        }
        tableView.reloadData()
    }
    
    func checkCountAndAlert() -> Bool {
        if config.otaCount > 0, successList.count + unusedList.count >= config.otaCount
        {
            // 增加停止ota代码
            stopBtnClick(nil)
            printLog("升级个数已经达到了，停止OTA了")
            
            VoiceSpeaker.shared.speak(text: "您好，您的 O T A 升级任务已完成", shouldLoop: true)
            let alert = UIAlertController(title: "温馨提醒", message: "您的OTA升级任务已完成", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好的", style: .cancel) { (action) in
                VoiceSpeaker.shared.stopSpeaking()
                
                let vc = ZdOtaResultVC()
                vc.failList = self.unusedList
                vc.successList = self.successList
                self.navigationController?.pushViewController(vc, animated: true)
            }
            alert.addAction(ok)
            navigationController?.present(alert, animated: true, completion: nil)
            return true
        }
        return false
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
        
        // 200行清一次数据
        if logLine > 200 {
            cleanLog()
        }
        
        logStr += "\(logLine). " + log + "\n"
        logTV.text = logStr
        logLine += 1
        logTV.scrollRangeToVisible(NSMakeRange(logStr.count - 1, 1))
    }
    
    private func cleanLog() {
        logStr = ""
        logLine = 1
    }
}
