//
//  ToolInitVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ToolInitVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, EditProtocolVCDelegate {
    
    var product: DeviceProduct!
    

    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "初始化配置"

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
        if let protos = product.initProtos
        {
            return protos.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(16)
        cell.textLabel?.text = product.initProtos![indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EditProtocolVC()
        vc.delegate = self
        vc.proto = product.initProtos![indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
