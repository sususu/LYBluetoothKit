//
//  StressTestingVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class StressTestingVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, AddDeviceCircleGroupVCDelegate, CircleTestGroupViewDelegate {

    @IBOutlet weak var logView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var nameTF: UITextField!
    
    var groups: [CircleGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].tests.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let ctg = CircleTestGroupView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40), index: section)
        ctg.update(withCg: groups[section])
        return ctg
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }


    // MARK: - 事件处理
    
    @IBAction func startTestBtnClick(_ sender: Any) {
        
    }
    
    
    @IBAction func addTestCircle(_ sender: Any) {
        let vc = AddDeviceCircleGroupVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func saveBtnClick(_ sender: Any) {
    }
    
    @IBAction func readBtnClick(_ sender: Any) {
    }
    
    // MARK: - 代理
    func didAddCircleGroup(_ testGroup: CircleGroup) {
        self.groups.append(testGroup)
        self.tableView.reloadData()
    }
    
    func cgvDidClickAdd(cg: CircleGroup) {
        let vc = AddDeviceCircleTestVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func cgvDidClickDel(cg: CircleGroup) {
        let alert = UIAlertController(title: nil, message: "您确定要删除", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            self.groups.remove(cg)
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
}
