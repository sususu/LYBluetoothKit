//
//  DeviceTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceTestVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var bleNameLbl: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hideShowBtn: UIButton!
    var product: DeviceProduct!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideShowBtn.setTitle(TR("展开"), for: .selected)
        hideShowBtn.setTitle(TR("隐藏"), for: .normal)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.register(UINib(nibName: "DeviceTestCell", bundle: nil), forCellReuseIdentifier: "cellId")
    }

    // MARK: - 事件处理
    // 自动连接
    @IBAction func autoConnectBtnClick(_ sender: Any) {
    }
    
    // 手动连接
    @IBAction func sdConnectBtnClick(_ sender: Any) {
    }
    
    // 屏蔽箱测试
    @IBAction func pbTestBtnClick(_ sender: Any) {
    }
    
    // 自动测试
    @IBAction func zdTestBtnClick(_ sender: Any) {
    }
    
    @IBAction func addTestBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        let vc = AddDeviceTestVC()
        vc.product = product
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return product.testGroups?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = product.testGroups?[section]
        return group?.testUnits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceTestCell
        let group = product.testGroups?[indexPath.section]
        cell.updateUI(withTestUnit: group!.testUnits![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return product.testGroups![section].name
    }
    
    
    
    // MARK: - 日志逻辑
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    @IBOutlet weak var logViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    @IBOutlet weak var loginTextView: UITextView!
    @IBOutlet weak var exportBtn: UIButton!
    @IBAction func exportBtnClick(_ sender: Any) {
    }
    
    @IBAction func hideShowBtnClick(_ sender: Any) {
        if hideShowBtn.isSelected {
            logViewHeight.constant = 200
            exportBtn.isHidden = false
            textViewRight.constant = 5
            textViewTop.constant = 5
        } else {
            logViewHeight.constant = 40
            exportBtn.isHidden = true
            textViewRight.constant = 50
            textViewTop.constant = -30
        }
        hideShowBtn.isSelected = !hideShowBtn.isSelected
    }
    
}
