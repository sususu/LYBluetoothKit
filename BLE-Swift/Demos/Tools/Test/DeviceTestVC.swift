//
//  DeviceTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DeviceTestCellDelegate, EditProtocolVCDelegate {

    @IBOutlet weak var ceshiConfigBtn: UIButton!
    
    @IBOutlet weak var editProtoBtn: UIButton!
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var bleNameLbl: UITextField!
    
    @IBOutlet weak var signalLbl: UITextField!
    
    
    @IBOutlet weak var nearestLbl: UILabel!
    
    
    var minSingal: Int = -70
    
    

    var product: DeviceProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bleNameLbl.text = product.bleName
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DeviceTestFunctionCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView.register(DeviceTestSubjectView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "subjectView")
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(moveAction(longGes:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(longPressGes)
        
        if AppConfig.current.roleType == .developer {
            setNavRightButton(text: "添加测试", sel: #selector(addTestBtnClick(_:)))
        } else {
            ceshiConfigBtn.isHidden = true
            editProtoBtn.isHidden = true
            headerHeight.constant = 170
        }
        
        showConnectState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
//        tableView.reloadData()
    }

    // MARK: - 事件处理
    // 自动连接
    private var toConnectDevice: BLEDevice?
    private var searchDevices: [BLEDevice] = []
    @IBAction func autoConnectBtnClick(_ sender: Any?) {
        guard let name = bleNameLbl.text, name.count > 0 else {
            showError("请输入蓝牙名称")
            return
        }
        self.searchDevices.removeAll()
        toConnectDevice = nil
        printLog("开始搜索设备")
        BLECenter.shared.scan(callback: { (devices, error) in
            if let ds = devices {
                
                let tmp = ds.sorted(by: { (d1, d2) -> Bool in
                    return d1.rssi > d2.rssi
                })
                if tmp.count > 0 {
                    let device = tmp[0]
                    self.nearestLbl.text = "信号：\(device.rssi ?? 0)";
                }
                
                self.searchDevices = ds.filter({ (d) -> Bool in
                    return (d.name.contains(name) && (d.rssi > self.minSingal))
                })
            }
        }, stop: {
            
            if self.searchDevices.count > 0 {
                self.searchDevices.sort(by: { (d1, d2) -> Bool in
                    return d1.rssi > d2.rssi
                })
                self.connectDevice(device: self.searchDevices[0])
            } else {
                self.autoConnectBtnClick(nil)
            }
        }, after: 5)
        
    }
    
    func connectDevice(device: BLEDevice) {
        printLog("连接设备：\(device.name)，信号：\(device.rssi ?? 0)")
        BLECenter.shared.connect(device: device, callback: { (d, err) in
            if let error = err {
                self.printLog(self.errorMsgFromBleError(error))
                self.autoConnectBtnClick(nil)
            } else {
                self.printLog("已连接上：\(device.name)")
                self.screenUpClick(nil)
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
//        if product.pbxCsUnits.count == 0 {
//            printLog("测试用例是空的，请点击“自测配置”进行配置")
//            return
//        }
//        if isZiCe {
//            printLog("正在测试，请不要重复点击")
//            return
//        }
//        isZiCe = true
//        zice(testUnits: product.pbxCsUnits, index: 0)
    }
    
    
    private var waitExcuteList: [Protocol] = []
    private var isExcuting: Bool = false
    func excute(proto: Protocol) {
        
        if isExcuting {
            waitExcuteList.append(proto)
            return
        }
        
        isExcuting = true
        
        self.printLog("执行：\(proto.name)")
        let runner = ProtocolRunner()
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.printLog(str)
            self.excuteFinish()
        }, stringCallback: { (str) in
            
            let result = "返回：" + str
//            if proto.name.hasSuffix("蓝牙地址") {
//                let bytes = str.data(using: .utf8)!.bytes;
//                let tmp = String(format: "%0.2X %0.2X %0.2X %0.2X %0.2X %0.2X", bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5])
//                result = "返回：" + tmp
//            }
            self.printLog(result)
            self.excuteFinish()
        }, dictCallback: { (dict) in
            let str = self.getJSONStringFromDictionary(dictionary: dict)
            self.printLog("返回：\(str)")
            self.excuteFinish()
        }, dictArrayCallback: { (dictArr) in
            let str = self.getJSONStringFromArray(array: dictArr)
            self.printLog("返回：\(str)")
            self.excuteFinish()
        }) { (error) in
            self.printLog("错误：" + self.errorMsgFromBleError(error))
            self.excuteFinish()
        }
    }
    
    func excuteFinish() {
        isExcuting = false
        if self.waitExcuteList.count > 0 {
            let toPro = self.waitExcuteList[0]
            self.waitExcuteList.remove(at: 0)
            excute(proto: toPro)
        }
    }
    
    
    // 自动测试
    @IBAction func zdTestBtnClick(_ sender: Any) {
        if product.ziceUnits.count == 0 {
            printLog("测试用例是空的，请点击“自测配置”进行配置")
            return
        }
        
        for unit in product.ziceUnits {
            excuteTest(testUnit: unit)
        }
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
        self.autoConnectBtnClick(nil)
    }
    
    
    @IBAction func zeceConfig(_ sender: Any) {
        let vc = TestConfigVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - 常规测试
    @IBAction func screenUpClick(_ sender: Any?) {
        
        guard let proto = product.screenUpProto, proto.cmdUnits.count > 0 else {
            let alert = UIAlertController(title: "亮屏", message: "还没有配置亮屏的执行指令，是否前往配置？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { (action) in
                self.product.screenUpProto = Protocol()
                let vc = EditProtocolVC()
                vc.proto = self.product.screenUpProto
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        printLog("执行：亮屏")
        let runner = ProtocolRunner()
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.printLog(str)
        }, stringCallback: { (str) in
        }, dictCallback: { (dict) in
        }, dictArrayCallback: { (dictArr) in
        }) { (error) in
            self.printLog("错误：" + self.errorMsgFromBleError(error))
        }
    }
    
    @IBAction func initBtnClick(_ sender: Any) {
        
        guard let protos = self.product.initProtos, protos.count > 0 else {
            let alert = UIAlertController(title: "初始化", message: "还没有配置'初始化'的执行指令，是否前往配置？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { (action) in
                let vc = ToolInitVC()
                vc.product = self.product
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        for proto in protos {
            
            excute(proto: proto)
            
        }
    }
    
    @IBAction func syncTimeBtnClick(_ sender: Any) {
        guard let proto = product.syncTimeProto, proto.cmdUnits.count > 0 else {
            let alert = UIAlertController(title: "同步时间", message: "还没有配置同步时间的执行指令，是否前往配置？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { (action) in
                self.product.syncTimeProto = Protocol()
                let vc = EditProtocolVC()
                vc.proto = self.product.syncTimeProto
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        printLog("执行：同步时间")
        let runner = ProtocolRunner()
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.printLog(str)
        }, stringCallback: { (str) in
        }, dictCallback: { (dict) in
        }, dictArrayCallback: { (dictArr) in
        }) { (error) in
            self.printLog("错误：" + self.errorMsgFromBleError(error))
        }
    }
    
    @IBAction func deviceInfoBtnClick(_ sender: Any) {
        
        guard let protos = self.product.infoProtos, protos.count > 0 else {
            let alert = UIAlertController(title: "查看信息", message: "还没有配置'查看信息'的执行指令，是否前往配置？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "确定", style: .default) { (action) in
                let vc = WatchInfoEditVC()
                vc.product = self.product
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.navigationController?.present(alert, animated: true, completion: nil)
            return
        }
        
        for proto in protos {
            
            excute(proto: proto)
            
        }
        
        
    }
    
    @IBAction func editBtnClick(_ sender: Any) {
        let vc = EditNormalTestVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didAddNewProtocol(protocol: Protocol) {
        ToolsService.shared.saveProduct(product)
    }
    
    func didEditNewProtocol(protocol: Protocol) {
        
    }
    
    // MARK: - 事件处理
    @objc func moveAction(longGes: UILongPressGestureRecognizer) {
        switch longGes.state {
        case .began:
            let indexPath = collectionView.indexPathForItem(at: longGes.location(in: longGes.view))
            if let ip = indexPath {
                collectionView.beginInteractiveMovementForItem(at: ip)
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(longGes.location(in: longGes.view))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func signalAddBtnClick(_ sender: Any) {
        
        let signal = Int(signalLbl.text ?? "") ?? 55
        signalLbl.text = "\(signal + 1)"
        
    }
    
    @IBAction func signalMinusBtnClick(_ sender: Any) {
        let signal = Int(signalLbl.text ?? "") ?? 55
        signalLbl.text = "\(signal - 1)"
    }
    
    
    // MARK: - collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return product.testGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = product.testGroups[section]
        return group.protocols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! DeviceTestFunctionCell
        let group = product.testGroups[indexPath.section]
        cell.updateUI(withProtocol: group.protocols[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "subjectView", for: indexPath) as! DeviceTestSubjectView
        view.setSubject(product.testGroups[indexPath.section].name)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let fromGroup = product.testGroups[sourceIndexPath.section]
        let fromItem = fromGroup.protocols[sourceIndexPath.item]
        
        fromGroup.protocols.remove(at: sourceIndexPath.item)
        
        let toGroup = product.testGroups[destinationIndexPath.section]
        toGroup.protocols.insert(fromItem, at: destinationIndexPath.item)
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return itemSizes[indexPath.row]
        return CGSize(width: 80, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: kScreenWidth, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let group = product.testGroups[indexPath.section]
        let proto = group.protocols[indexPath.row]
        
        excute(proto: proto)
    }
    
    
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
//            self.tableView.reloadData()
            self.showSuccess(TR("Success"))
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 代理
    func dtcAddLog(log: String)
    {
        printLog(log)
    }
    
    func dtcShowAlert(title: String?, msg: String)
    {
        
    }
    
    // MARK: - 自动测试
    private var waitTestList: [DeviceTestUnit] = []
    private var isTesting: Bool = false
    func excuteTest(testUnit: DeviceTestUnit) {
        
        if isTesting {
            waitTestList.append(testUnit)
            return
        }
        
        isTesting = true
        
        let proto = testUnit.prol!
        self.printLog("执行：\(proto.name)")
        let runner = ProtocolRunner()
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.printLog(str)
            self.excuteTestFinish(after: testUnit.ceshiTime)
        }, stringCallback: { (str) in
            
            var result = "返回：" + str
            if proto.name.hasSuffix("蓝牙地址") {
                let bytes = str.data(using: .utf8)!.bytes;
                if bytes.count >= 6 {
                    let tmp = String(format: "%0.2X %0.2X %0.2X %0.2X %0.2X %0.2X", bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5])
                    result = "返回：" + tmp
                }
            }
            self.printLog(result)
            self.excuteTestFinish(after: testUnit.ceshiTime)
        }, dictCallback: { (dict) in
            let str = self.getJSONStringFromDictionary(dictionary: dict)
            self.printLog("返回：\(str)")
            self.excuteTestFinish(after: testUnit.ceshiTime)
        }, dictArrayCallback: { (dictArr) in
            let str = self.getJSONStringFromArray(array: dictArr)
            self.printLog("返回：\(str)")
            self.excuteTestFinish(after: testUnit.ceshiTime)
        }) { (error) in
            self.printLog("错误：" + self.errorMsgFromBleError(error))
            self.excuteTestFinish(after: testUnit.ceshiTime)
        }
    }
    
    func excuteTestFinish(after: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            self.isTesting = false
            if self.waitTestList.count > 0 {
                let toTest = self.waitTestList[0]
                self.waitTestList.remove(at: 0)
                self.excuteTest(testUnit: toTest)
            }
        }
    }
    
    
    // MARK: - 日志逻辑
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var logViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    @IBOutlet weak var loginTextView: UITextView!
    @IBOutlet weak var exportBtn: UIButton!
    
    @IBAction func exportBtnClick(_ sender: Any) {
        if exportBtn.isSelected
        {
            logViewHeight.constant = 130
            exportBtn.setTitle("全屏", for: .normal)
        }
        else
        {
            logViewHeight.constant = kScreenHeight
            exportBtn.setTitle("缩小", for: .normal)
        }
        exportBtn.isSelected = !exportBtn.isSelected
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
