//
//  SDOtaVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SDOtaVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    let kNameKey = "kNameKey"
    let kTypeKey = "kTypeKey"
    let kFirmwaresKey = "kFirmwaresKey"

    var config: OtaConfig!
    var firmwaresArr : [Dictionary<String, Any>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var startStopBtn: UIButton!
    
    @IBOutlet weak var progressLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showConnectState()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
    
        startStopBtn.layer.cornerRadius = 40
        startStopBtn.layer.masksToBounds = true
        
        progressView.layer.cornerRadius = 8
        progressView.layer.masksToBounds = true
        progressView.progress = 0.3
        
        setNavRightButton(text: TR("Home"), sel: #selector(backToHome))
        
        parseConfigAndUpdateUI()
    }
    
    // MARK: - 业务逻辑
    func parseConfigAndUpdateUI() {
        
        nameLbl.text = config.deviceName
        
        for fm in config.firmwares {
            
            var f = true
            
            for dict in firmwaresArr {
                let type = dict[kTypeKey] as! OtaDataType
                if type == fm.type {
                    f = false
                }
                var arr = dict[kFirmwaresKey] as! Array<Firmware>;
                arr.append(fm)
            }
            
            if f {
                let name = TR("升级列表(") + Firmware.getTypeName(withType: fm.type) + ")"
                var arr = [Firmware]();
                arr.append(fm)
                
                var dict = Dictionary<String, Any>()
                dict[kNameKey] = name
                dict[kTypeKey] = fm.type
                dict[kFirmwaresKey] = arr
                
                firmwaresArr.append(dict)
            }
        }
        
        tableView.reloadData()
        
    }
    

    // MARK: - 事件处理
    @IBAction func deviceIdBtnClick(_ sender: Any) {
    }
    
    @IBAction func versionBtnClick(_ sender: Any) {
    }
    
    @IBAction func resetBtnClick(_ sender: Any) {
    }
    
    @objc func backToHome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return firmwaresArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = firmwaresArr[section][kFirmwaresKey] as! Array<Firmware>
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let arr = firmwaresArr[indexPath.section][kFirmwaresKey] as! Array<Firmware>
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.font = font(12)
        cell.textLabel?.textColor = rgb(80, 80, 80)
        cell.textLabel?.text = arr[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return firmwaresArr[section][kNameKey] as? String
    }
}
