//
//  OtaTaskDetailVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaTaskDetailVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TR("OTA Tasks")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TaskDetailCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 60
        
        setNavRightButton(text: TR("CANCEL All"), sel: #selector(stopAllBtnClick))
    }


    // MARK: - 事件处理
    @objc func stopAllBtnClick() {
        alert(msg: TR("Are you sure cancel all OTA tasks ?"), confirmText: TR("YES"), confirmSel: #selector(doCancelAllTask), cancelText: TR("NO"), cancelSel: nil)
    }
    
    @objc func doCancelAllTask() {
        OtaManager.shared.cancelAllTask()
        tableView.reloadData()
        return
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OtaManager.shared.taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TaskDetailCell
        cell.updateUI(withTask: OtaManager.shared.taskList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        OtaManager.shared.cancelTask(OtaManager.shared.taskList[indexPath.row])
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}
