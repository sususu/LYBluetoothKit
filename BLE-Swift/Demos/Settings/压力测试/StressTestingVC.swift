//
//  StressTestingVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class StressTestingVC: BaseViewController,
UITableViewDataSource,
UITableViewDelegate,
AddDeviceCircleGroupVCDelegate,
CircleTestGroupViewDelegate,
AddDeviceCircleTestVCDelegate,
DeviceTestConfigsVCDelegate,
BLEDeviceDelegate
{
    @IBOutlet weak var logView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var startStopBtn: UIButton!

    
    var groups: [CircleGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        startStopBtn.setTitle("停止测试", for: .selected)
        startStopBtn.backgroundColor = rgb(80, 80, 80)
        
        setNavRightButton(text: "清除链接", sel: #selector(clearConnection))
        
        nameTF.text = "Helio #99999"
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].tests.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let ctg = CircleTestGroupView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), index: section)
        ctg.update(withCg: groups[section])
        ctg.delegate = self
        return ctg
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        }
        cell!.textLabel?.font = font(16)
        cell!.detailTextLabel?.font = font(14)
        cell!.detailTextLabel?.textColor = rgb(180, 180, 180)
        
        let ct = groups[indexPath.section].tests[indexPath.row]
        
        cell!.textLabel?.text = ct.name
        cell!.detailTextLabel?.text = "\(ct.span)秒后执行"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }


    // MARK: - 事件处理
    @objc func clearConnection() {
        if let d = self.device {
            if d.state == .ready {
                BLECenter.shared.disconnect(device: d, callback: { (d, err) in
                    self.device = nil
                    self.showSuccess("成功")
                })
            }
            else {
                self.device = nil
                self.showSuccess("成功")
            }
        } else {
            self.showSuccess("成功")
        }
    }
    
    private var isTesting: Bool = false
    
    @IBAction func startTestBtnClick(_ sender: Any?) {
        if isTesting
        {
            isTesting = false
            startStopBtn.backgroundColor = rgb(80, 80, 80)
            startStopBtn.isSelected = false
            stopTest()
        }
        else
        {
            isTesting = true
            startStopBtn.backgroundColor = rgb(230, 40, 40)
            startStopBtn.isSelected = true
            isStop = false
            i = 0
            j = 0
            repeatCount = 0
            
            if groups.count == 0 {
                printError(err: "测试内容不能为空")
                return
            }
            
            startTest()
        }
    }
    
    private var i = 0
    private var j = 0
    private var repeatCount = 0
    func startTest() {
        
        self.view.endEditing(true)
        
        guard let name = nameTF.text, name.count > 0 else {
            printError(err: "请输入要测试的蓝牙名称")
            return
        }
        
        
        if groups.count <= i {
            printInfo(info: "测试完成了")
            startTestBtnClick(nil)
            return
        }
        
        if groups[i].tests.count == 0 {
            printInfo(info: "当前测试组里面，没有测试操作，“被认为”完成了")
            startTestBtnClick(nil)
            return
        }
        
        if groups[i].tests.count <= j {
            j = 0
            repeatCount += 1
            if groups[i].repeatCount <= repeatCount {
                i += 1
            }
            startTest()
            return
        }
        
        
        let ct = groups[i].tests[j]
        DispatchQueue.main.asyncAfter(deadline: .now() + ct.span) {
            self.doTest(ct)
        }
    }
    
    private var device: BLEDevice?
    
    func searchDevice(_ ct: CircleTest) {
        
        if isStop {
            return
        }
        
        guard let name = nameTF.text else {
            printError(err: "请输入要测试的蓝牙名称")
            return
        }
        printInfo(info: "正在查找：\(name)")
        BLECenter.shared.scan(callback: { (devices, err) in
            if let ds = devices {
                for d in ds {
                    if d.name == name {
                        self.device = d
                        self.printInfo(info: "找到了！")
                        BLECenter.shared.stopScan()
                        self.doTest(ct)
                    }
                }
            }
        }, stop: {
            if self.device == nil {
                self.printError(err: "搜索不到: \(name)，2秒之后重新搜索")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.searchDevice(ct)
                })
            }
        }, after: 5)
    }
    
    func doTest(_ ct: CircleTest) {
        
        if isStop {
            return
        }
        
        if device == nil {
            printInfo(info: "开始搜索设备")
            searchDevice(ct)
            return
        }
        
        j += 1
        
        switch ct.type {
        case .connect:
            guard let name = nameTF.text else {
                printError(err: "请输入要测试的蓝牙名称")
                return
            }
            if device != nil && device!.name == name {
                printInfo(info: "开始链接设备：\(name)")
                BLECenter.shared.connect(device: device!, callback: { (d, err) in
                    if err != nil {
                        self.printError(err: "链接设备发生错误：\(err.debugDescription)")
                        return
                    }
                    self.printInfo(info: "已经链接上！")
                    self.device = d
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.startTest()
                    })
                })
            }
            else {
                printInfo(info: "开始搜索链接设备：\(name)")
                BLECenter.shared.connect(deviceName: name, callback: { (d, err) in
                    if err != nil {
                        self.printError(err: "链接设备发生错误：\(err.debugDescription)")
                        return
                    }
                    self.printInfo(info: "已经链接上！")
                    self.device = d
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.startTest()
                    })
                })
            }
        case .disconnect:
            if device != nil && device!.state == .ready {
                printInfo(info: "开始断链设备：\(device!.name)")
                BLECenter.shared.disconnect(device: device!, callback: { (d, err) in
                    if err != nil {
                        self.printError(err: "断链设备发生错误：\(err.debugDescription)")
                        return
                    }
                    self.printInfo(info: "已经断链了！")
                    self.device = d
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.startTest()
                    })
                    
                })
            }
            else
            {
                printError(err: "设备已经断链了，还要进行断链吗？")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.startTest()
                })
            }
        case .cmd:
            if device != nil && device!.state == .ready {
                guard let data = ct.hexData.hexadecimal else {
                    printError(err: "发送数据转换失败：\(ct.hexData)")
                    return
                }
                printInfo(info: "向 \(device!.name) 写：\(ct.hexData)")
                _ = device!.write(data, characteristicUUID: UUID.c8001)
            }
            else
            {
                printError(err: "设备已经断链了，发指令不行")
            }
        }
    }
    
    func deviceDidUpdateData(data: Data, deviceName: String, uuid: String) {
        printInfo(info: "接收到来自 \(deviceName) 的：\(data.hexEncodedString())")
    }
    
    
    private var isStop = false
    func stopTest() {
        isStop = true
    }
    
    
    
    @IBAction func addTestCircle(_ sender: Any) {
        let vc = AddDeviceCircleGroupVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func saveBtnClick(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "给它起个名字吧", preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "测试名称"
        }
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            guard let text = alert.textFields![0].text, text.count > 0 else {
                self.showError("请输入名称")
                return
            }
            let ct = DeviceTestConfig(name: text, groups: self.groups)
            if CircleTestService.shared.configs.contains(ct) {
                self.showError("已经有相同名字啦")
                return
            }
            
            CircleTestService.shared.configs.insert(ct, at: 0)
            CircleTestService.shared.saveConfigs()
            self.showSuccess("添加成功")
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func readBtnClick(_ sender: Any) {
        let vc = DeviceTestConfigsVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 代理
    func didAddCircleGroup(_ testGroup: CircleGroup) {
        if self.groups.contains(testGroup) {
            showError("已经存在相同名字的组，请重新添加")
            return
        }
        self.groups.append(testGroup)
        self.tableView.reloadData()
    }
    
    func cgvDidClickAdd(cg: CircleGroup) {
        let vc = AddDeviceCircleTestVC()
        vc.group = cg
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func cgvDidClickDel(cg: CircleGroup) {
        let alert = UIAlertController(title: nil, message: "您确定要删除", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            self.groups.remove(cg)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func didAddDeviceCT(ct: CircleTest, forGroup:CircleGroup) {
        forGroup.tests.append(ct)
        self.tableView.reloadData()
    }
    
    func didSelectDTConfig(config: DeviceTestConfig) {
        self.groups = config.groups
        self.tableView.reloadData()
    }
    
    
    func printInfo(info: String) {
        let attr = NSMutableAttributedString(string: info + "\n")
        attr.addAttribute(.foregroundColor, value: UIColor.green, range: NSMakeRange(0, attr.length))
        attr.addAttribute(.font, value: font(10), range: NSMakeRange(0, attr.length))
        addAttrStr(str: attr)
    }
    
    func printError(err: String) {
        let attr = NSMutableAttributedString(string: err + "\n")
        attr.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, attr.length))
        attr.addAttribute(.font, value: font(10), range: NSMakeRange(0, attr.length))
        addAttrStr(str: attr)
    }
    
    func addAttrStr(str: NSAttributedString) {
        DispatchQueue.main.async {
            let attr = NSMutableAttributedString(string: "\(self.logLine). ")
            self.logLine += 1
            attr.addAttribute(.foregroundColor, value: UIColor.white, range: NSMakeRange(0, attr.length))
            attr.addAttribute(.font, value: font(10), range: NSMakeRange(0, attr.length))
            attr.append(str)
            self.logStr.append(attr)
            self.logView.attributedText = self.logStr
//            self.logView.text = self.logStr.string
//            self.logView.setContentOffset(CGPoint(x: 0, y: self.logView.contentSize.height), animated: true)
            self.logView.scrollRangeToVisible(NSMakeRange(self.logStr.string.count - 1, 1))
        }
        
    }
    
    // 日志
    private var logStr: NSMutableAttributedString = NSMutableAttributedString(string: "")
    private var logLine = 1
}
