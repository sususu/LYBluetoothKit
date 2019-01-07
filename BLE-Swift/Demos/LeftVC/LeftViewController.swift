//
//  LeftViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

/// userInfo: device: BLEDevice
let kEditDeviceNotification = NSNotification.Name("kEditDeviceNotification")


class LeftViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, SlideMenuControllerDelegate, LeftDeviceCellDelegate {
    
    
    @IBOutlet weak var disconnectBtn: UIButton!
    
    @IBOutlet weak var refreshBtn: RefreshBtn!
    @IBOutlet weak var refreshBtnLeft: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewWidth: NSLayoutConstraint!
    
    
    var devices = Array<BLEDevice>()
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        createViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        scanDevices()
    }
    
    // MARK: - 初始化
    func createViews() {
        
        tableViewWidth.constant = SlideMenuOptions.leftViewWidth;
        refreshBtnLeft.constant = SlideMenuOptions.leftViewWidth - refreshBtn.bounds.width - 20
        
        tableView.register(UINib(nibName: "LeftDeviceCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60;
        
    }
    
    // MARK: - 业务逻辑
    func scanDevices() {
        // 说明已经正在扫描
        if (refreshBtn.isLoading) {
            return
        }
        weak var weakSelf = self;
        BLECenter.shared.scan(callback: { (devices, error) in
            weakSelf?.refreshBtn.startLoading()
            if error != nil {
                weakSelf?.handleBleError(error: error)
                return
            }
            weakSelf?.devices = devices ?? Array<BLEDevice>();
            weakSelf?.tableView.reloadData()
        }, stop: {
            weakSelf?.refreshBtn.stopLoading()
        }, after: 10);
    }
    
    func connect(device: BLEDevice, atIndex:Int) {
        weak var weakSelf = self
        self.startLoading(nil)
        BLECenter.shared.connect(device: device, callback: { (d, err) in
            if err != nil {
                weakSelf?.handleBleError(error: err)
            } else {
                weakSelf?.showSuccess(TR("Connected"))
                weakSelf?.devices.remove(at: atIndex)
                weakSelf?.devices.insert(d!, at: atIndex)
                weakSelf?.tableView.reloadData()
            }
        });
    }
    
    
    // MARK: - 事件处理
    @IBAction func disconnectBtnClick(_ sender: Any) {
        
    }
    
    @IBAction func refreshBtnClick(_ sender: Any) {
        scanDevices()
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! LeftDeviceCell
        cell.updateUI(withDevice: self.devices[indexPath.row])
        cell.delegate = self;
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.refreshBtn.isLoading {
            return
        }
        
        let device = self.devices[indexPath.row]
        connect(device: device, atIndex: indexPath.row)
    }

    // MARK: - 代理实现
    func didClickEditBtn(cell: UITableViewCell)
    {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let device = self.devices[indexPath.row]
        
        NotificationCenter.default.post(name: kEditDeviceNotification, object: nil, userInfo: ["device": device])
        
        let vc = DeviceInfoViewController(device: device)
        let nav = LYNavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}
