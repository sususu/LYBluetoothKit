//
//  ProtocolManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import MJRefresh

class ProtocolManagerVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, ProtocolObjCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var protocolList: [ProtocolObj] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProtocolObjCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 60
        
        setNavRightButton(text: "上传", sel: #selector(uploadAction))
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadProtocolList))
        header?.activityIndicatorViewStyle = .gray
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        self.tableView.mj_header = header
        
//        loadProtocolList()
        self.tableView.mj_header.beginRefreshing()
    }
    
    @objc func uploadAction() {
        if !User.current.isLogin {
            showError("请先登录")
            return
        }
        
        let alert = UIAlertController(title: nil, message: "请指定一个名字吧", preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            guard let name = alert.textFields![0].text, name.count > 0 else {
                self.showError("请输入名字");
                return
            }
            self.startUpload(withName: name)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 业务逻辑
    func startUpload(withName name: String) {
        
        guard let json = ProtocolService.shared.getMenusJsonData() else {
            showError("本地协议信息为空")
            return
        }
        
        let protocolStr = String(bytes: json, encoding: .utf8) ?? ""
        
        let params = ["name": name, "protocol": protocolStr]
        
        startLoading(nil)
        NetworkManager.shared.post(API_PROTOCOL_UPLOAD, params: params, callback: { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            self.showSuccess("上传成功")
        }, addParamToURL: false)
    }
    
    @objc func loadProtocolList() {
//        if !self.tableView.mj_header.isRefreshing {
//            self.tableView.mj_header.beginRefreshing()
//        }
        NetworkManager.shared.get(API_PROTOCOL_LIST, params: nil) { (resp) in
            self.stopLoading()
            self.tableView.mj_header.endRefreshing()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            self.protocolList.removeAll()
            guard let dictArr = resp.data as? Array<Dictionary<String, Any>> else {
                self.tableView.reloadData()
                return
            }
            
            for dict in dictArr {
                let id = (dict["id"] as? Int) ?? 0
                let name = (dict["name"] as? String) ?? ""
                let updateTime = (dict["updateTime"] as? Int) ?? 0
                let userName = (dict["username"] as? String) ?? ""
                let userId = (dict["userId"] as? Int) ?? 0
                
                let po = ProtocolObj(id: id, name: name)
                po.updateTime = updateTime
                po.userName = userName
                po.userId = userId
                
                self.protocolList.append(po);
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - 事件处理

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.protocolList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ProtocolObjCell
        cell.updateUI(withProtocolObj: self.protocolList[indexPath.row])
        cell.accessoryType = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        poDidClickMerge(cell: tableView.cellForRow(at: indexPath)!)
    }
    
    func poDidClickMerge(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let po = self.protocolList[indexPath.row]
        
        let alert = UIAlertController(title: "非常重要", message: "是否要覆盖本地的协议配置信息？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { (letion) in
            self.loadDetailAndMerget(po: po)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    func loadDetailAndMerget(po: ProtocolObj) {
        
        startLoading(nil)
        NetworkManager.shared.get(API_PROTOCOL_UPLOAD + "/\(po.id)", params: nil) { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            
            guard let dict = resp.data as? Dictionary<String, Any> else {
                self.showError("无法解析数据")
                return
            }
            
            guard let proto = (dict["protocol"] as? String), proto.count > 0 else {
                self.showError("协议数据为空，无法合并")
                return
            }
            
            guard let data = proto.data(using: String.Encoding.utf8) else {
                self.showError("协议数据为空，无法合并!")
                return
            }
            _ = StorageUtils.save(data, forKey: ProtocolService.kMenusCacheKey)
            ProtocolService.shared.refreshMenusFromDisk()
            self.showSuccess("合并成功")
        }
    }
    
}
