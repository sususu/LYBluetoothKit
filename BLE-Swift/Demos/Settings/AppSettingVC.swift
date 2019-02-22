//
//  AppSettingVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class AppSettingVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections: [MenuSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMenus()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
    }

    // MARK: - 业务逻辑
    func createMenus() {
        let fmSection = MenuSection(title: "")
        sections.append(fmSection)
        
        let settingSection = MenuSection(title: "")
        sections.append(settingSection)
        
        let fmRow = MenuRow(title: "修改名称", icon: nil, selector: nil, pushVC: "FirmwareManagerVC")
        let xyRow = MenuRow(title: "修改密码", icon: nil, selector: nil, pushVC: "ProtocolManagerVC")
        let gjRow = MenuRow(title: "忘记密码", icon: nil, selector: nil, pushVC: "ToolManagerVC")
        
        fmSection.rows = [MenuRow]()
        fmSection.rows?.append(fmRow)
        fmSection.rows?.append(xyRow)
        fmSection.rows?.append(gjRow)
        
        
        let settingRow = MenuRow(title: "退出登录", icon: nil, selector: "Logout", pushVC: nil)
        settingSection.rows = [MenuRow]()
        settingSection.rows?.append(settingRow)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows![indexPath.row]
        
        if let sel = row.selector {
            
            if sel == "Logout" {
                User.current.logout()
                showSuccess("成功")
                navigationController?.popToRootViewController(animated: true);
            }
            
        } else {
            var nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            nameSpace = nameSpace.replacingOccurrences(of: "-", with: "_")
            let cls = NSClassFromString(nameSpace + "." + row.pushVC!) as! UIViewController.Type
            let vc = cls.init()
            vc.title = row.title
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
