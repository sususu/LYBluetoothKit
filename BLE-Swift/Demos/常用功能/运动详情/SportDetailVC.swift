//
//  SportDetailVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SportDetailVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sports: Array<Sport>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "运动详情"

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "SportDetailCell", bundle: nil), forCellReuseIdentifier: "cellId")
        self.tableView.rowHeight = 160
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SportDetailCell
        cell.updateUI(withSport: sports[indexPath.row])
        return cell
    }
    

}
