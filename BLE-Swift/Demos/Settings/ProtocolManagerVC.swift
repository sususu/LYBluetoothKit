//
//  ProtocolManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolManagerVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        
        setNavRightButton(text: "上传", sel: #selector(uploadAction))
    }
    
    @objc func uploadAction() {
        
    }
    
    // MARK: - 事件处理

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
