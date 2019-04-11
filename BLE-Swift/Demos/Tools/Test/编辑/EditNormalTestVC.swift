//
//  EditNormalTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class EditNormalTestVC: BaseViewController, EditProtocolVCDelegate, UITableViewDataSource, UITableViewDelegate {

    var product: DeviceProduct!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DeviceTestCell", bundle: nil), forCellReuseIdentifier: "cellId")

        self.title = "编辑常规测试"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @IBAction func screenUpBtnClick(_ sender: Any) {
        if self.product.screenUpProto == nil {
            self.product.screenUpProto = Protocol()
        }
        
        let vc = EditProtocolVC()
        vc.proto = self.product.screenUpProto
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func initBtnClick(_ sender: Any) {
        let vc = ToolInitVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func syncTimeBtnClick(_ sender: Any) {
        if self.product.syncTimeProto == nil {
            self.product.syncTimeProto = Protocol()
        }
        
        let vc = EditProtocolVC()
        vc.proto = self.product.syncTimeProto
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func infoBtnClick(_ sender: Any) {
        let vc = WatchInfoEditVC()
        vc.product = self.product
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func didAddNewProtocol(protocol: Protocol) {
        
    }
    
    func didEditNewProtocol(protocol: Protocol) {
        
    }

    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return product.testGroups.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = product.testGroups[section]
        return group.protocols.count
    }
    
    private var rowActions: [UITableViewRowAction] = []
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if rowActions.count == 0 {
            let row1 = UITableViewRowAction(style: .normal, title: "编辑") { (rowAction, ip) in
                self.editRow(atIndexPath: ip)
            }
            let row2 = UITableViewRowAction(style: .destructive, title: "删除") { (rowAction, ip) in
                self.deleteRow(atIndexPath: ip)
            }
            rowActions.append(row1)
            rowActions.append(row2)
        }
        return rowActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editRow(atIndexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - 编辑菜单项
    func editRow(atIndexPath indexPath: IndexPath) {
        let vc = AddDeviceTestVC()
        vc.product = product
        vc.oldGroup = product.testGroups[indexPath.section]
        vc.proto = product.testGroups[indexPath.section].protocols[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteRow(atIndexPath indexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            let tg = self.product.testGroups[indexPath.section]
            tg.protocols.remove(at: indexPath.row)
            ToolsService.shared.saveProductsToDisk()
            self.tableView.reloadData()
            self.showSuccess(TR("Success"))
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceTestCell
        let group = product.testGroups[indexPath.section]
        cell.updateUI(withProtocol: group.protocols[indexPath.row])
//        cell.delegate = self
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return product.testGroups[section].name
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if product.testGroups[section].protocols.count == 0 {
            return 0
        }
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if product.testGroups[section].protocols.count == 0 {
            return nil
        }
        
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 15))
        lbl.font = font(10)
        lbl.textColor = rgb(120, 120, 120)
        lbl.text = "    " + product.testGroups[section].name
        lbl.backgroundColor = UIColor.white
        return lbl
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
