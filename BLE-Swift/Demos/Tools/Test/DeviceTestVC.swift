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
        
        bleNameLbl.text = product.bleName
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "DeviceTestCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        setNavRightButton(text: "添加测试", sel: #selector(addTestBtnClick(_:)))
        
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
    private var isZiCe: Bool = false
    @IBAction func pbTestBtnClick(_ sender: Any) {
        if product.pbxCsUnits.count == 0 {
            printLog("测试用例是空的，请点击“自测配置”进行配置")
            return
        }
        if isZiCe {
            printLog("正在测试，请不要重复点击")
            return
        }
        isZiCe = true
        zice(testUnits: product.pbxCsUnits, index: 0)
    }
    
    func zice(testUnits:[DeviceTestUnit], index: Int) {
        
        if index == testUnits.count {
            printLog("测试结束！！！！！！")
            isZiCe = false
            return
        }
        
        let tu = testUnits[index]
        
        let runner = ProtocolRunner()
        runner.run(tu.prol, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.printLog(str)
            self.zice(testUnits: testUnits, index: index + 1)
        }, stringCallback: { (str) in
            let result = "返回：" + str
            self.printLog(result)
            self.zice(testUnits: testUnits, index: index + 1)
        }, dictCallback: { (dict) in
            let str = self.getJSONStringFromDictionary(dictionary: dict)
            self.printLog("返回：\(str)")
            self.zice(testUnits: testUnits, index: index + 1)
        }, dictArrayCallback: { (dictArr) in
            let str = self.getJSONStringFromArray(array: dictArr)
            self.printLog("返回：\(str)")
            self.zice(testUnits: testUnits, index: index + 1)
        }) { (error) in
            self.printLog("错误：" + self.errorMsgFromBleError(error))
            self.zice(testUnits: testUnits, index: index + 1)
        }
        
    }
    
    
    // 自动测试
    @IBAction func zdTestBtnClick(_ sender: Any) {
        if product.ziceUnits.count == 0 {
            printLog("测试用例是空的，请点击“自测配置”进行配置")
            return
        }
        if isZiCe {
            printLog("正在测试，请不要重复点击")
            return
        }
        isZiCe = true
        zice(testUnits: product.ziceUnits, index: 0)
    }
    
    @IBAction func addTestBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        let vc = AddDeviceTestVC()
        vc.product = product
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func resetBtnClick(_ sender: Any) {
        printLog("重置设置...")
        
        _ = BLECenter.shared.resetDevice(boolCallback: { (bool, error) in
            
        }, toDeviceName: nil)
    }
    
    
    @IBAction func disconnectBtnClick(_ sender: Any) {
        BLECenter.shared.disconnectAllConnectedDevices()
        printLog("已断开全部连接设备")
    }
    
    
    @IBAction func zeceConfig(_ sender: Any) {
        let vc = TestConfigVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return product.testGroups.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = product.testGroups[section]
        return group.protocols.count
    }
    
    private var rowActions: [UITableViewRowAction] = []
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if rowActions.count == 0 {
            let row1 = UITableViewRowAction(style: .normal, title: "编辑") { (rowAction, ip) in
                self.editRow(atIndexPath: ip)
            }
            let row2 = UITableViewRowAction(style: .destructive, title: "删除") { (rowAction, ip) in
                self.deleteRow(atIndexPath: ip)
            }
            rowActions.append(row1)
            rowActions.append(row2)
        }
        return rowActions
    }
    
    // MARK: - 编辑菜单项
    func editRow(atIndexPath indexPath: IndexPath) {
        let vc = AddDeviceTestVC()
        vc.product = product
        vc.oldGroup = product.testGroups[indexPath.section]
        vc.proto = product.testGroups[indexPath.section].protocols[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteRow(atIndexPath indexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            let tg = self.product.testGroups[indexPath.section]
            tg.protocols.remove(at: indexPath.row)
            ToolsService.shared.saveProductsToDisk()
            self.tableView.reloadData()
            self.showSuccess(TR("Success"))
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceTestCell
        let group = product.testGroups[indexPath.section]
        cell.updateUI(withProtocol: group.protocols[indexPath.row])
        cell.delegate = self
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return product.testGroups[section].name
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if product.testGroups[section].protocols.count == 0 {
            return 0
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if product.testGroups[section].protocols.count == 0 {
            return nil
        }
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 15))
        lbl.font = font(10)
        lbl.textColor = rgb(120, 120, 120)
        lbl.text = "    " + product.testGroups[section].name
        lbl.backgroundColor = UIColor.white
        return lbl
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
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
            logViewHeight.constant = 220
//            exportBtn.isHidden = false
            textViewRight.constant = 5
            textViewTop.constant = 5
        } else {
            logViewHeight.constant = 40
//            exportBtn.isHidden = true
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
    
    
    
    func getJSONStringFromDictionary(dictionary:Dictionary<String, Any>) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        
        return String(bytes: data ?? Data(), encoding: .utf8) ?? "";
    }
    
    //数组转json
    func getJSONStringFromArray(array:Array<Dictionary<String, Any>>) -> String {
        
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data = try? JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        let JSONString = String(bytes:data ?? Data(), encoding: .utf8) ?? ""
        return JSONString
        
    }
}
