//
//  StressTestingVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class StressTestingVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var logView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var nameTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }


    // MARK: - 事件处理
    
    @IBAction func startTestBtnClick(_ sender: Any) {
        
    }
    
    
    @IBAction func addTestCircle(_ sender: Any) {
    }
    

    @IBAction func saveBtnClick(_ sender: Any) {
    }
    
    @IBAction func readBtnClick(_ sender: Any) {
    }
    
}
