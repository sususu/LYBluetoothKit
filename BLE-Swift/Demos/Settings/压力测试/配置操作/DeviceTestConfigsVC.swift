//
//  DeviceTestConfigsVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol DeviceTestConfigsVCDelegate: NSObjectProtocol {
    func didSelectDTConfig(config: DeviceTestConfig)
}

class DeviceTestConfigsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var configs = CircleTestService.shared.configs
    
    var delegate: DeviceTestConfigsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "配置读取"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(16)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = configs[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectDTConfig(config: configs[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        configs.remove(at: indexPath.row)
        CircleTestService.shared.saveConfigs()
        tableView.beginUpdates()
        tableView.deleteRow(at: indexPath, with: .automatic)
        tableView.endUpdates()
    }

}
