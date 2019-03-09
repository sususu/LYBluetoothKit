//
//  EnumManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol EnumManagerVCDelegate: NSObjectProtocol {
    func didSelect(enumObj: EnumObj)
}

class EnumManagerVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, EditEnumVCDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: EnumManagerVCDelegate?
    
    var enumObjs: [EnumObj] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择枚举"
        
        enumObjs = EnumService.shared.enums
        
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 60
    
        setNavRightButton(text: "添加", sel: #selector(addEnumBtnClick))
    }
    
    
    @objc func addEnumBtnClick() {
        let vc = EditEnumVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enumObjs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(enumObj: enumObjs[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowActions = [UITableViewRowAction(style: .destructive, title: "删除", handler: { (action, indexPath) in
            
            self.enumObjs.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRow(at: indexPath, with: .automatic)
            tableView.endUpdates()
            EnumService.shared.saveEnums()
            
        }), UITableViewRowAction(style: .normal, title: "编辑", handler: { (action, indexPath) in
            let vc = EditEnumVC()
            vc.enumObj = self.enumObjs[indexPath.row]
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        })]
        return rowActions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        }
        cell!.textLabel?.text = enumObjs[indexPath.row].name
        cell!.textLabel?.font = font(16)
        cell!.textLabel?.textColor = kMainColor
        cell!.detailTextLabel?.textColor = rgb(200, 30, 30)
        cell!.detailTextLabel?.font = font(12)
        cell!.accessoryType = .disclosureIndicator
        
        var txt = ""
        for i in 0 ..< enumObjs[indexPath.row].labelArr.count {
            let lbl = enumObjs[indexPath.row].labelArr[i];
            let v = enumObjs[indexPath.row].valueArr[i];
            txt += lbl + "-\(v), "
        }
        // 去掉最后面的 逗号 和 空格
        txt = String(txt.prefix(txt.count - 2))
        cell!.detailTextLabel?.text = txt
        
        return cell!;
    }
    
    func didFinishEditEnum(enumObj: EnumObj) {
        enumObjs = EnumService.shared.enums
        tableView.reloadData()
    }
    
}
