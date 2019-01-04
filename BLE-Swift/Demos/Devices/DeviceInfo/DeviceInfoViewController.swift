//
//  DeviceInfoViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/4.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, CharacteristicCellTableViewCellDelegate {
    
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
    }
    
    func configNav() {
        self.title = TR("Device Information")
        setNavLeftButton(withIcon: "fanhui", sel: #selector(backClick))
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
    
    func didClickSendBtn(cell: UITableViewCell) {
        
    }
}
