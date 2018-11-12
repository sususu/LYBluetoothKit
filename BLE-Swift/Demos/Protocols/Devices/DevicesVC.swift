//
//  DevicesVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/17.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

class DevicesVC: BaseTableViewController {
    
    var sections:[TableSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        // 创建菜单
        let sec1 = TableSection(name: "DeviceID")
        let m11 = TableMenu(name: "GetDeviceID", type: .method, operation: "getDeviceID")
        sec1.menus.append(m11)

        sections.append(sec1)

    }
    
    // MARK: Methods
    @objc func getDeviceID() {
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getDeviceID(stringCallback: { (str, err) in
            weakSelf?.stopLoading()
            if err != nil {
                weakSelf?.alert(msg: err.debugDescription)
            } else {
                weakSelf?.alert(msg: "ID---->\(str ?? "--")")
            }
        })
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = sections[section]
        return sec.menus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let sec = sections[indexPath.section]
        let menu = sec.menus[indexPath.row]
        cell.textLabel?.text = menu.name
        cell.detailTextLabel?.text = menu.descri
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sec = sections[indexPath.section]
        let menu = sec.menus[indexPath.row]
        
        switch menu.type {
        case .method:
            let sel = NSSelectorFromString(menu.operation)
            if self.responds(to: sel) {
                self.performSelector(onMainThread: sel, with: nil, waitUntilDone: false)
            }
        case .push:
            guard let cls = NSClassFromString(menu.operation) as? UIViewController.Type else {
                break
            }
            let vc = cls.init()
            navigationController?.pushViewController(vc, animated: true)
            
        case .present:
            guard let cls = NSClassFromString(menu.operation) as? UIViewController.Type else {
                break
            }
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            navigationController?.present(nav, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sec = sections[section]
        return sec.name
    }
    
}
