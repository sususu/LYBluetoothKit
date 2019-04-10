//
//  WatchInfoEditVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/9.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class WatchInfoEditVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, EditProtocolVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var product: DeviceProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "查看信息配置"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 50
        
        setNavRightButton(text: "增加步骤", sel: #selector(addStepBtnClick))
    }


    // MARK: - 事件处理
    @objc func addStepBtnClick() {
        let vc = EditProtocolVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didAddNewProtocol(protocol proto: Protocol) {
        if product.initProtos == nil {
            product.initProtos = []
        }
        product.initProtos!.append(proto)
        ToolsService.shared.saveProduct(product)
        tableView.reloadData()
    }
    
    func didEditNewProtocol(protocol proto: Protocol) {
        ToolsService.shared.saveProduct(product)
        tableView.reloadData()
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let protos = product.infoProtos
        {
            return protos.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(16)
        cell.textLabel?.text = "\(indexPath.row + 1) - " + product.infoProtos![indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditProtocolVC()
        vc.delegate = self
        vc.proto = product.infoProtos![indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        product.infoProtos!.remove(at: indexPath.row)
        ToolsService.shared.saveProduct(product)
        tableView.reloadData()
    }

}
