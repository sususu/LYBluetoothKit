//
//  DeviceTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, DeviceTestCellDelegate {

    @IBOutlet weak var bleNameLbl: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hideShowBtn: UIButton!
    var product: DeviceProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideShowBtn.setTitle(TR("展开"), for: .selected)
        hideShowBtn.setTitle(TR("隐藏"), for: .normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "DeviceTestCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        showConnectState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - 事件处理
    // 自动连接
    private var toConnectDevice: BLEDevice?
    private var searchDevices: [BLEDevice] = []
    @IBAction func autoConnectBtnClick(_ sender: Any) {
        guard let name = bleNameLbl.text, name.count > 0 else {
            showError("请输入蓝牙名称")
            return
        }
        toConnectDevice = nil
        printLog("开始搜索设备")
        BLECenter.shared.scan(callback: { (devices, error) in
            if let ds = devices {
                self.searchDevices = ds.filter({ (d) -> Bool in
                    return d.name.contains(name)
                })
            }
        }, stop: {
            
            if self.searchDevices.count > 0 {
                self.searchDevices.sort(by: { (d1, d2) -> Bool in
                    return d1.rssi > d2.rssi
                })
                self.connectDevice(device: self.searchDevices[0])
            }
        }, after: 5)
        
    }
    
    func connectDevice(device: BLEDevice) {
        printLog("连接设备：\(device.name)")
        BLECenter.shared.connect(device: device, callback: { (d, err) in
            if let error = err {
                self.printLog(self.errorMsgFromBleError(error))
            } else {
                self.printLog("已连接上：\(device.name)")
            }
        })
    }
    
    // 手动连接
    @IBAction func sdConnectBtnClick(_ sender: Any) {
        let vc = ConnectVC()
        vc.filteredName = bleNameLbl.text
        let nav = UINavigationController(rootViewController: vc)
        navigationController?.present(nav, animated: true, completion: nil)
    }
    
    // 屏蔽箱测试
    @IBAction func pbTestBtnClick(_ sender: Any) {
    }
    
    // 自动测试
    @IBAction func zdTestBtnClick(_ sender: Any) {
    }
    
    @IBAction func addTestBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        let vc = AddDeviceTestVC()
        vc.product = product
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return product.testGroups.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = product.testGroups[section]
        return group.protocols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceTestCell
        let group = product.testGroups[indexPath.section]
        cell.updateUI(withProtocol: group.protocols[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return product.testGroups[section].name
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - 代理
    func dtcAddLog(log: String)
    {
        printLog(log)
    }
    
    func dtcShowAlert(title: String?, msg: String)
    {
        
    }
    
    
    // MARK: - 日志逻辑
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var logViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    @IBOutlet weak var loginTextView: UITextView!
    @IBOutlet weak var exportBtn: UIButton!
    @IBAction func exportBtnClick(_ sender: Any) {
    }
    
    @IBAction func hideShowBtnClick(_ sender: Any) {
        if hideShowBtn.isSelected {
            logViewHeight.constant = 200
            exportBtn.isHidden = false
            textViewRight.constant = 5
            textViewTop.constant = 5
        } else {
            logViewHeight.constant = 40
            exportBtn.isHidden = true
            textViewRight.constant = 50
            textViewTop.constant = -30
        }
        hideShowBtn.isSelected = !hideShowBtn.isSelected
    }
    
    // 日志
    private var logStr = ""
    private var logLine = 1
    private func printLog(_ log: String) {
        logStr += "\(logLine). " + log + "\n"
        loginTextView.text = logStr
        logLine += 1
        loginTextView.scrollRangeToVisible(NSMakeRange(logStr.count - 1, 1))
    }
}
