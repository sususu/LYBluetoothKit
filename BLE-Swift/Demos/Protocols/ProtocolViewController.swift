//
//  ProtocolViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var seg: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var docController: UIDocumentInteractionController?
    
    var protocolMenus: Array<ProtocolMenu>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataAndRefresUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProtocolMenuCell", bundle: nil), forCellReuseIdentifier: "cellId")
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 80))
        tableView.rowHeight = 55
        // Do any additional setup after loading the view.
        
        setNavLeftButton(text: TR("导出"), sel: #selector(exportBtnClick))
        setNavRightButton(text: TR("添加"), sel: #selector(addBtnClick(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(menusChangedNotification), name: kProtocolMenusChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        seg.selectedSegmentIndex = BLEConfig.shared.shouldSend03End ? 0 : 1
    }
    
    @objc func menusChangedNotification() {
        protocolMenus = ProtocolService.shared.protocolMenus
        tableView.reloadData()
    }
    
    func loadDataAndRefresUI() {
        protocolMenus = ProtocolService.shared.protocolMenus
        tableView.reloadData()
    }
    

    // MARK: - 事件处理
    @IBAction func addBtnClick(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: TR("Please input name"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.createNewMenu(withName: alert.textFields![0].text ?? "")
        }
        let cancel = UIAlertAction(title: TR("NO"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (tf) in
            tf.placeholder = TR("协议分组名称")
            tf.becomeFirstResponder()
        }
        navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    func createNewMenu(withName name: String) {
        let menu = ProtocolMenu(name: name, createTime: Date().timeIntervalSince1970)
        if protocolMenus.contains(menu) {
            showError("这个名称已经存在了")
            return
        }
        protocolMenus.insert(menu, at: 0)
        ProtocolService.shared.addMenu(menu: menu)
        tableView.reloadData()
        showSuccess(TR("Success"))
    }
    
    
    @objc func exportBtnClick() {
        
        guard let data = ProtocolService.shared.getMenusJsonData() else {
            showError("获取数据失败")
            return
        }
        
        guard let url = StorageUtils.saveAsFile(forData: data, fileName: "BLE-Appscomm_ProtocolMenus.json") else {
            showError("保存协议菜单文件失败")
            return
        }
        
        if docController == nil {
            docController = UIDocumentInteractionController(url: url)
        }
        docController!.delegate = self
        docController?.name = "BLE-Appscomm_ProtocolMenus.json"
        
        docController!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
        
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        
    }
    
    @IBAction func send03OrNotChanged(_ sender: UISegmentedControl) {
        BLEConfig.shared.shouldSend03End = (sender.selectedSegmentIndex == 0)
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
        let vc = ProtocolMenuDetailsVC(menu: menu)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            let menu = self.protocolMenus[indexPath.row]
            self.protocolMenus.remove(menu)
            ProtocolService.shared.deleteMenu(menu: menu)
            self.showSuccess(TR("Success"))
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
