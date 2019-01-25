//
//  ProtocolViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var protocolMenus: Array<ProtocolMenu>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataAndRefresUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProtocolMenuCell", bundle: nil), forCellReuseIdentifier: "cellId")
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 80))
        tableView.rowHeight = 45
        // Do any additional setup after loading the view.
        
        setNavLeftButton(text: TR("导出"), sel: #selector(exportBtnClick))
        setNavRightButton(text: TR("添加"), sel: #selector(addBtnClick(_:)))
    }
    
    func loadDataAndRefresUI() {
        protocolMenus = ProtocolJsonParser.shared.parser(jsonFileName: "Protocol.json")
        tableView.reloadData()
    }
    

    // MARK: - 事件处理
    @IBAction func addBtnClick(_ sender: Any) {
    }
    
    @objc func exportBtnClick() {
        
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return protocolMenus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ProtocolMenuCell
        cell.updateUI(withMenu: self.protocolMenus[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let menu = self.protocolMenus[indexPath.row]
        let vc = ProtocolMenuDetailsVC(protocols: menu.protocols)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
