//
//  TestConfigVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/27.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TestConfigVC: BaseViewController,
UITableViewDataSource,
UITableViewDelegate {
    
    @IBOutlet weak var stepTableView: UITableView!
    
    @IBOutlet weak var testsTableView: UITableView!
    
    @IBOutlet weak var durationTF: UITextField!
    
    
    var product: DeviceProduct!
    var testUnits: [DeviceTestUnit] = []
    var ziceUnits: [DeviceTestUnit] = []
    
//    var protos:[Protocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "自动测试配置"
        
        for group in product.testGroups {
            for proto in group.protocols {
                let dt = DeviceTestUnit(name: proto.name, createTime: Date().timeIntervalSinceNow)
                dt.prol = proto
                testUnits.append(dt)
            }
        }
        
        ziceUnits = product.ziceUnits
        
        stepTableView.dataSource = self
        stepTableView.delegate = self
        stepTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        testsTableView.dataSource = self
        testsTableView.delegate = self
        testsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        setNavRightButton(text: "保存", sel: #selector(saveConfig))
        
    }

    
    // MARK: - 事件处理
    @objc func saveConfig() {
        
        product.ziceUnits = ziceUnits
        
        ToolsService.shared.saveProduct(product)
        showSuccess("保存成功")
    }

    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == stepTableView {
            return ziceUnits.count
        } else {
            return testUnits.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var title = testUnits[indexPath.row].name
        if tableView == stepTableView
        {
            title = ziceUnits[indexPath.row].name + "  -  \(ziceUnits[indexPath.row].ceshiTime)秒"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(12)
        cell.textLabel?.textColor = rgb(150, 150, 150)
        if tableView == stepTableView {
            cell.textLabel?.textColor = rgb(200, 130, 130)
        }
        cell.textLabel?.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == stepTableView {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == testsTableView {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if tableView == testsTableView {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        ziceUnits.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRow(at: indexPath, with: .automatic)
        tableView.endUpdates()
    }
    
    
    // MARK: - 事件处理
    @IBAction func addBtnClick(_ sender: Any) {
        guard let durStr = durationTF.text, durStr.count > 0 else {
            showError("请输入测试秒钟")
            return
        }
        guard let indexPath = testsTableView.indexPathForSelectedRow else {
            showError("请选择测试用例")
            return
        }
        let dt = testUnits[indexPath.row]
        dt.ceshiTime = Double(durStr) ?? 2
        ziceUnits.append(dt)
        stepTableView.reloadData()
        
        durationTF.text = ""
        testsTableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
    }
    
    
    @IBAction func editBtnClick(_ sender: Any) {
        stepTableView.setEditing(true, animated: true)
    }
    
    
}
