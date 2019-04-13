//
//  ConnectVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/9/20.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

class ConnectVC: BaseTableViewController, LeftDeviceCellDelegate, UISearchBarDelegate {

    var devices:[BLEDevice] = []
    var filteredDevices: [BLEDevice] = []
    var numLbl:NumberView!
    
    var searchBar: UISearchBar!
    
    var filteredName: String?
    
    var connectSingleOne = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "LeftDeviceCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        NotificationCenter.default.addObserver(self, selector: #selector(backClick), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
        searchBar.delegate = self
        searchBar.placeholder = TR("Search by name")
        searchBar.text = filteredName
        tableView.tableHeaderView = searchBar
        
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
        
        let btnWidth:CGFloat = 44
        let btnHeight:CGFloat = 44
        
        let btn = UIButton(type: .custom)
        let image = UIImage(named: "shuaxin2")
        btn.setImage(image, for: .normal)
        
        btn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        btn.addTarget(self, action: #selector(searchDevices), for: .touchUpInside)
        
        let btn2 = UIButton(type: .custom)
        btn2.setTitle("排序", for: .normal)
        btn2.titleLabel?.font = font(14)
        btn2.setTitleColor(kMainColor, for: .normal)
        
        btn2.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        btn2.addTarget(self, action: #selector(sortDevices), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: btn), UIBarButtonItem(customView: btn2)]
    }
    
    
    @objc func searchDevices() {
        self.filteredDevices.removeAll()
        BLECenter.shared.scan(callback: { (devices, err) in
            
            self.devices = devices ?? []
            self.filterDevices(withName: self.searchBar.text)
            
        }, stop: {
            print("结束扫描")
        })
    }
    
    @objc func sortDevices() {
        sortAndReloadTableView()
    }
    
    
    @objc func showConnectedDevices() {
        let devicesVC = DevicesViewController()
        navigationController?.pushViewController(devicesVC, animated: true)
    }
    
    func didClickEditBtn(cell: UITableViewCell) {
        
    }
    
    // MARK: - 代理
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterDevices(withName: searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func filterDevices(withName name: String?) {
        var devices = self.filteredDevices
        guard let str = name, str.count > 0 else {
            for d in self.devices {
                if !devices.contains(d) {
                    devices.append(d)
                }
            }
            self.filteredDevices = devices
//            sortAndReloadTableView()
            tableView.reloadData()
            return
        }
        
        devices = devices.filter ({ (d) -> Bool in
            return d.name.contains(str)
        })
        
        let otherDevices = self.devices.filter { (d) -> Bool in
            return d.name.contains(str)
        }
        
        for d in otherDevices {
            if !devices.contains(d) {
                devices.append(d)
            }
        }
        self.filteredDevices = devices
        
//        self.filteredDevices = self.devices.filter({ (p) -> Bool in
//            return p.name.contains(str)
//        })
        
        tableView.reloadData()
    }
    
    func sortAndReloadTableView() {
        self.filteredDevices.sort { (d1, d2) -> Bool in
            if d1.rssi == d2.rssi {
                return d1.name > d2.name
            } else {
                return d1.rssi > d2.rssi
            }
        }
        tableView.reloadData()
    }
    
    
    // MARK: - tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDevices.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! LeftDeviceCell
        let device = self.filteredDevices[indexPath.row]
        cell.updateUI(withDevice: device)
        cell.delegate = self;
        cell.setDebugHidden(hidden: true)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BLECenter.shared.stopScan()
        self.startLoading(nil)
        let device = self.filteredDevices[indexPath.row]
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
