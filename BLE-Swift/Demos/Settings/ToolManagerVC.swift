//
//  ToolManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import MJRefresh

class ToolManagerVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, ToolsObjCellDelegate {
    
    var toolsList: [ToolsObj] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ToolsObjCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 60
        
        setNavRightButton(text: "上传", sel: #selector(uploadAction))
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadToolsList))
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
        
        guard let json = ToolsService.shared.getJsonData() else {
            showError("本地工具信息为空")
            return
        }
        
        let toolsStr = String(bytes: json, encoding: .utf8) ?? ""
        
        let params = ["name": name, "tools": toolsStr]
        
        startLoading(nil)
        NetworkManager.shared.post(API_TOOLS_UPLOAD, params: params, callback: { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            self.showSuccess("上传成功")
        }, addParamToURL: false)
    }
    
    @objc func loadToolsList() {

        NetworkManager.shared.get(API_TOOLS_LIST, params: nil) { (resp) in
            self.stopLoading()
            self.tableView.mj_header.endRefreshing()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            self.toolsList.removeAll()
            guard let dictArr = resp.data as? Array<Dictionary<String, Any>> else {
                self.tableView.reloadData()
                return
            }
            
            for dict in dictArr {
                let id = (dict["id"] as? Int) ?? 0
                let name = (dict["name"] as? String) ?? ""
                let bleName = (dict["bleName"] as? String) ?? ""
                let updateTime = (dict["updateTime"] as? Int) ?? 0
                let userName = (dict["username"] as? String) ?? ""
                let userId = (dict["userId"] as? Int) ?? 0
                
                let po = ToolsObj(id: id, name: name)
                po.bleName = bleName
                po.updateTime = updateTime
                po.userName = userName
                po.userId = userId
                
                self.toolsList.append(po);
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - 事件处理
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.toolsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ToolsObjCell
        cell.updateUI(withToolsObj: self.toolsList[indexPath.row])
        cell.accessoryType = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toolsDidClickMerge(cell: tableView.cellForRow(at: indexPath)!)
    }
    
    func toolsDidClickMerge(cell: UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let po = self.toolsList[indexPath.row]
        
        let alert = UIAlertController(title: "非常重要", message: "是否要覆盖本地（相同名字项目）的工具配置信息？", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { (letion) in
            self.loadDetailAndMerget(po: po)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (action) in
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
    func loadDetailAndMerget(po: ToolsObj) {
        
        startLoading(nil)
        NetworkManager.shared.get(API_TOOLS_UPLOAD + "/\(po.id)", params: nil) { (resp) in
            self.stopLoading()
            if resp.code != 0 {
                self.showError(resp.msg)
                return
            }
            
            guard let dict = resp.data as? Dictionary<String, Any> else {
                self.showError("无法解析数据")
                return
            }
            
            guard let proto = (dict["tools"] as? String), proto.count > 0 else {
                self.showError("工具数据为空，无法合并")
                return
            }
            
            guard let data = proto.data(using: String.Encoding.utf8) else {
                self.showError("工具数据为空，无法合并!")
                return
            }
            
            if let tmp: [DeviceProduct] = try? JSONDecoder().decode([DeviceProduct].self, from: data) {
                for dp in tmp {
                    ToolsService.shared.products.remove(dp)
                }
                
                for dp in tmp {
                    ToolsService.shared.products.insert(dp, at: 0)
                }
                
            }
            ToolsService.shared.saveProductsToDisk()
            ToolsService.shared.refreshToolsFromDisk()
            self.showSuccess("合并成功")
        }
    }

}
