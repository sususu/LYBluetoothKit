//
//  ConnectVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/9/20.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

class ConnectVC: BaseTableViewController, LeftDeviceCellDelegate {

    var devices:[BLEDevice] = []
    var numLbl:NumberView!
    
    var connectSingleOne = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "LeftDeviceCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        configNav()
        
        searchDevices()
    }
    
    func configNav() {

        numLbl = NumberView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        numLbl!.addTarget(self, action: #selector(showConnectedDevices), for: .touchUpInside)
        self.navigationItem.titleView = numLbl
        self.numLbl.num = BLECenter.shared.connectedDevices.count
        
        setNavRightButton(withIcon: "shuaxin2", sel: #selector(searchDevices))
        setNavLeftButton(withIcon: "fanhui", sel: #selector(backClick))
    }
    
    
    @objc func searchDevices() {
        BLECenter.shared.scan(callback: { (devices, err) in
            
            self.devices = devices ?? []
            self.tableView.reloadData()
            
        }, stop: {
            print("结束扫描")
        })
    }
    
    @objc func showConnectedDevices() {
        let devicesVC = DevicesViewController()
        navigationController?.pushViewController(devicesVC, animated: true)
    }
    
    func didClickEditBtn(cell: UITableViewCell) {
        
    }
    
    // MARK: - tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! LeftDeviceCell
        let device = self.devices[indexPath.row]
        cell.updateUI(withDevice: device)
        cell.delegate = self;
        cell.setDebugHidden(hidden: true)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BLECenter.shared.stopScan()
        self.startLoading(nil)
        let device = self.devices[indexPath.row]
        BLECenter.shared.connect(device: device, callback: { (device, err) in
            self.stopLoading()
            if err != nil {
                self.handleBleError(error: err!)
            } else {
                self.showSuccess(TR("Connected"))
                self.numLbl.num = BLECenter.shared.connectedDevices.count
                if self.connectSingleOne {
                    self.backClick()
                }
            }
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func backClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
