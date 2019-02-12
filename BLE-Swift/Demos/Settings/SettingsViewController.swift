//
//  SettingsViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [MenuSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createMenus()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        reloadData()
    }
    
    // MARK: - 业务逻辑
    func createMenus() {
        let fmSection = MenuSection(title: "")
        sections.append(fmSection)
        
        let settingSection = MenuSection(title: "")
        sections.append(settingSection)
        
        let fmRow = MenuRow(title: "固件管理", icon: nil, selector: nil, pushVC: "FirmwareManagerVC")
        let xyRow = MenuRow(title: "协议配置", icon: nil, selector: nil, pushVC: "ProtocolManagerVC")
        let gjRow = MenuRow(title: "工具配置", icon: nil, selector: nil, pushVC: "ToolManagerVC")
        
        fmSection.rows = [MenuRow]()
        fmSection.rows?.append(fmRow)
        fmSection.rows?.append(xyRow)
        fmSection.rows?.append(gjRow)
        
        
        let settingRow = MenuRow(title: "账号设置", icon: nil, selector: nil, pushVC: "AppSettingVC")
        settingSection.rows = [MenuRow]()
        settingSection.rows?.append(settingRow)
    }

    func reloadData() {
        nameLbl.isHidden = true
        emailLbl.isHidden = true
    }
    

    // MARK: - 事件处理
    
    @IBAction func loginBtnClick(_ sender: Any) {
        
        let vc = LoginVC()
//        let nav = LYNavigationController(rootViewController: vc)
//        navigationController?.present(nav, animated: true, completion: nil)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = sections[section].rows else {
            return 0
        }
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let row = sections[indexPath.section].rows![indexPath.row]
        cell.textLabel?.text = row.title
        cell.imageView?.image = UIImage(named: row.icon ?? "")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].titleHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footerHeight
    }
}
