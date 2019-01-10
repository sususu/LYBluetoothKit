//
//  ProtocolMenuDetailsVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenuDetailsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var protocols: Array<Protocol>
    
    var runner = ProtocolRunner()
    
    
    init(protocols: Array<Protocol>) {
        self.protocols = protocols
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProtocolMenuDetailCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 80))
        
        showConnectState()
    }


    // MARK: - 事件处理
    @IBAction func addBtnClick(_ sender: Any) {
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return protocols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ProtocolMenuDetailCell
        cell.updateUI(withProtocol: self.protocols[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        weak var weakSelf = self
        runner.run(self.protocols[indexPath.row], boolCallback: { (bool) in
            
        }, stringCallback: { (str) in
            weakSelf?.alert(msg: (str ?? ""), confirmSel: nil, cancelText: nil, cancelSel: nil)
        }, dictCallback: { (dict) in
            
        }, dictArrayCallback: { (dicts) in
            
        }) { (err) in
            weakSelf?.handleBleError(error: err)
        }
    }
}
