//
//  ConnectVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/9/20.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

class ConnectVC: BaseTableViewController {

    var devices:[BLEDevice] = []
    var numLbl:NumberView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Connect"

        self.tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "cellId")

        setNavLeftButton(text: "Scan", sel: #selector(searchDevices))
        
        numLbl = NumberView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        numLbl!.addTarget(self, action: #selector(showConnectedDevices), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: numLbl!)
        
        searchDevices()
    }
    
    @objc func searchDevices() {
        BLECenter.shared.scan(callback: { (devices, err) in
            
            self.devices = devices!
            self.tableView.reloadData()
            
        }, stop: {
            print("结束扫描")
        })
    }
    
    @objc func showConnectedDevices() {
        let devicesVC = DevicesViewController()
        navigationController?.pushViewController(devicesVC, animated: true)
    }
    
    
    // MARK: - tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceCell
        let device = self.devices[indexPath.row]
        cell.updateUI(withDevice: device)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.startLoading(nil)
        let device = self.devices[indexPath.row]
        BLECenter.shared.connect(device: device, callback: { (device, err) in
            self.stopLoading()
            if err != nil {
                self.showError("连接设备出错")
            } else {
                self.showSuccess("连接成功")
                self.numLbl?.num = BLECenter.shared.connectedDevices.count
            }
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
