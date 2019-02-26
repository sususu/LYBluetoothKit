//
//  DeviceInfoViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CharacteristicCellTableViewCellDelegate, CmdKeyBoardViewDelegate {
    
    var device: BLEDevice
    
    @IBOutlet weak var deviceNameLbl: UILabel!
    
    @IBOutlet weak var uuidLbl: UILabel!
    
    @IBOutlet weak var stateLbl: UILabel!

    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var disconnectBtn: UIButton!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var deviceInfos: Array<DeviceInfo>!
    
    init(device: BLEDevice) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNav()
        createView()
        
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataUpdate), name: BLEInnerNotification.deviceDataUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DeviceResponseLogView.create()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DeviceResponseLogView.destroy()
    }
    
    
    func configNav() {
        self.title = TR("Device Information")
        setNavLeftButton(withIcon: "fanhui", sel: #selector(backClick))
        setNavRightButton(text: TR("日志"), sel: #selector(showLogBtnClick))
    }

    func createView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CharacteristicCellTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        reloadData()
    }
    
    func reloadData() {
        
        deviceInfos = generateInfos(withDevice: device)
        
        deviceNameLbl.text = device.name
        uuidLbl.text = "UUID: " + device.name
        
        if device.state == .disconnected {
            stateLbl.text = TR("Disconnected")
            stateLbl.textColor = rgb(200, 30, 30)
            
            connectBtn.isHidden = false
            disconnectBtn.isHidden = true
            
        } else {
            stateLbl.text = TR("Connected")
            stateLbl.textColor = rgb(30, 200, 30)
            
            connectBtn.isHidden = true
            disconnectBtn.isHidden = false
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - 业务逻辑
    func generateInfos(withDevice deive:BLEDevice) -> Array<DeviceInfo> {
        
        var deviceInfoArr = Array<DeviceInfo>();
        
        // advertisement data
        let adInfo = DeviceInfo(type: .advertisementData)
        adInfo.name = TR("ADVERTISEMENT DATA")
        deviceInfoArr.append(adInfo)
        
        for (uuid, service) in device.services {
            let sInfo = DeviceInfo(type: .service, uuid: uuid, name: "", properties: "", id: uuid)
            deviceInfoArr.append(sInfo)
            
            guard let characteristics = service.characteristics else {
                continue
            }
            
            for ch in characteristics {
                let uuid = ch.uuid.uuidString
                let name = uuid.count > 4 ? "Characteristic  " + uuid.suffix(4) : "Characteristic  " + uuid
                var properties = ""
                if ch.properties.contains(.read) {
                    properties += "Read "
                }
                if ch.properties.contains(.write) {
                    properties += "Write "
                }
                if ch.properties.contains(.writeWithoutResponse) {
                    properties += "Write Without Response "
                }
                if ch.properties.contains(.notify) {
                    properties += "Notify"
                }
                
                let cInfo = DeviceInfo(type: .characteristic, uuid: uuid, name: name, properties: properties, id: uuid)
                sInfo.subItems.append(cInfo)
            }
        }
        
        return deviceInfoArr;
    }
    
    
    // MARK: - 事件处理
    @objc func backClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func connectBtnClick(_ sender: Any) {
        startLoading(nil)
        weak var weakSelf = self
        BLECenter.shared.connect(device: device, callback:{ (d, err) in
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showSuccess(TR("Connected"))
                weakSelf?.device = d!;
                weakSelf?.reloadData()
            }
        })
    }
    
    @IBAction func disconnectBtnClick(_ sender: Any) {
        startLoading(nil)
        weak var weakSelf = self
        BLECenter.shared.disconnect(device: device, callback:{ (d, err) in
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showSuccess(TR("Connected"))
                weakSelf?.device = d!;
                weakSelf?.reloadData()
            }
        })
    }
    
    @objc func showLogBtnClick() {
        DeviceResponseLogView.show()
    }
    
    
    // MARK: - 代理
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return deviceInfos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dInfo = deviceInfos[section]
        return dInfo.subItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! CharacteristicCellTableViewCell
        let dInfo = deviceInfos[indexPath.section]
        cell.updateUI(withDeviceInfo: dInfo.subItems[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let dInfo = deviceInfos[section]
        if dInfo.type == .advertisementData {
            return dInfo.name
        } else {
            return "UUID: " + dInfo.uuid
        }
    }
    
    private var keyboard = CmdKeyBoardView()
    private var textField: UITextField?
    func didClickSendBtn(cell: UITableViewCell) {
        
        let indexPath = tableView.indexPath(for: cell)!
        let dInfo = deviceInfos[indexPath.section]
        let cInfo = dInfo.subItems[indexPath.row]
        
        keyboard.delegate = self
        let alert = UIAlertController(title: nil, message: "输入要发送的数据（16进制）", preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            if self.device.state == .ready {
                guard let sendStr = alert.textFields![0].text, sendStr.count > 0 else {
                    self.showError("不能发送空的")
                    return
                }
                self.printLog(log: "向 \(cInfo.uuid) 发送数据：\(sendStr)")
                _ = self.device.write(sendStr.hexadecimal ?? Data(), characteristicUUID: cInfo.uuid)
            } else {
                self.printLog(log: "设备断连了，无法发送数据")
            }
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addTextField { (textField) in
            textField.font = font(12)
            textField.inputView = self.keyboard
            self.textField = textField
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func didEnterStr(str: String) {
        if str.hasPrefix("Str") ||
            str.hasPrefix("Int") ||
            str.hasPrefix("Len") {
            return
        }
        textField?.text = (textField?.text ?? "") + str
    }
    
    func didFinishInput() {
        
    }
    func didFallback() {
        
        guard let text = textField?.text, text.count > 0 else {
            return
        }
        
        textField?.text = String(text.prefix(text.count - 1))
    }
    
    
    
    @objc func deviceDataUpdate(notification: Notification) {
        guard let uuid = notification.userInfo?[BLEKey.uuid] as? String else {
            return
        }
        guard let data = notification.userInfo?[BLEKey.data] as? Data else {
            return
        }
        
        guard let device = notification.userInfo?[BLEKey.device] as? BLEDevice else {
            return
        }
        
        if device == self.device {
            DeviceResponseLogView.printLog(log: "(\(uuid)) recv data:\(data.hexEncodedString())")
            DeviceResponseLogView.show()
        }
        
//        if uuid == self.data.recvFromUuid && device == self.device {
//            parser.standardParse(data: data, sendData: self.data.sendData, recvCount: self.data.recvDataCount)
//        }
        
    }
    
    func printLog(log: String) {
        DeviceResponseLogView.printLog(log: log)
    }
}
