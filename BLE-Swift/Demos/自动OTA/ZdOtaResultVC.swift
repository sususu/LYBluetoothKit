//
//  ZdOtaResultVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ZdOtaResultVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var successList: [ZdOtaTask]!
    var failList: [ZdOtaTask]!
    
    var seg: UISegmentedControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        seg = UISegmentedControl(items: ["成功(\(successList.count))", "失败(\(failList.count))"])
        seg.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        seg.addTarget(self, action: #selector(segChanged(seg:)), for: .valueChanged)
        seg.tintColor = kMainColor
        seg.selectedSegmentIndex = 0
        navigationItem.titleView = seg
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ZdOtaResultCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // MARK: - 事件处理
    @objc func segChanged(seg: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // MARK: - tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if seg.selectedSegmentIndex == 0 {
            return successList.count
        } else {
            return failList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ZdOtaResultCell
        if seg.selectedSegmentIndex == 0 {
            cell.updateUI(withTask: successList[indexPath.row], isSuccess: true)
        } else {
            cell.updateUI(withTask: failList[indexPath.row], isSuccess: false)
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
//        
//    }
    
}
