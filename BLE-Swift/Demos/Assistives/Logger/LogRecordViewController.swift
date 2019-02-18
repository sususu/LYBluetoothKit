//
//  LogRecordViewController.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/14.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class LogRecordViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recordTableView: UITableView!
    
    private let logger = Logger.shared();
    
    // MARK:UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logger.logRecordsArr.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LogRecordTableViewCell = recordTableView.dequeueReusableCell(withIdentifier: LogRecordTableViewCell.getReuseIdentifier(), for: indexPath) as! LogRecordTableViewCell
        
        
        cell.label.text = logger.logRecordsArr[indexPath.row];
        
        return cell;
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recordTableView.register(LogRecordTableViewCell.getNib(), forCellReuseIdentifier: LogRecordTableViewCell.getReuseIdentifier())
        recordTableView.estimatedRowHeight = 200
        recordTableView.rowHeight = UITableView.automaticDimension

        self.setNavLeftButton(text: "Dismiss", sel: #selector(dismissNav))
    }

    @objc func dismissNav() {
        self.navigationController?.dismiss(animated: true, completion: nil);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
