//
//  EditEnumVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol EditEnumVCDelegate: NSObjectProtocol {
    func didFinishEditEnum(enumObj: EnumObj)
}

class EditEnumVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var itemNameTF: UITextField!
    
    @IBOutlet weak var itemValueInput: NumberInputView!
    
    private var mjArr:[(String, Int)] = []
    
    var delegate: EditEnumVCDelegate?
    
    var enumObj: EnumObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "编辑枚举"
        view.backgroundColor = rgb(240, 240, 240)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 40

        setNavRightButton(text: "保存枚举", sel: #selector(saveEnumClick))
        
        
        if let eo = enumObj {
            nameTF.text = eo.name
            for i in 0 ..< eo.labelArr.count {
                let lbl = eo.labelArr[i]
                let v = eo.valueArr[i]
                mjArr.append((lbl, v))
            }
            tableView.reloadData()
        }
        
    }


    @IBAction func saveBtnClick(_ sender: Any) {
        guard let name = itemNameTF.text, name.count > 0 else {
            return
        }
        guard let num = Int(itemValueInput.textField.text ?? "") else {
            return
        }
        
        itemNameTF.text = ""
        itemValueInput.jiaBtnClick()
        mjArr.append((name, num))
        mjArr.sort { (e1, e2) -> Bool in
            return e1.1 < e2.1
        }
        tableView.reloadData()
    }
    
    @objc func saveEnumClick() {
        self.view.endEditing(true)
        
        guard let name = nameTF.text, name.count > 0 else {
            showError("请输入枚举名称")
            return
        }
        
        if mjArr.count == 0 {
            showError("请添加枚举项目")
            return
        }
        
        var eo = enumObj
        if eo == nil {
            eo = EnumObj()
        }
        eo!.name = name
        eo!.labelArr.removeAll()
        eo!.valueArr.removeAll()
        for e in mjArr {
            eo!.labelArr.append(e.0)
            eo!.valueArr.append(e.1)
        }
        
        if EnumService.shared.enums.contains(eo!) {
            EnumService.shared.enums.remove(eo!)
        }
        EnumService.shared.enums.insert(eo!, at: 0)
        EnumService.shared.saveEnums()
        
        delegate?.didFinishEditEnum(enumObj: eo!)
        self.navigationController?.popViewController(animated: true)
        showSuccess("保存成功")
    }

    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mjArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = mjArr[indexPath.row].0 + ": \(mjArr[indexPath.row].1)"
        cell.textLabel?.font = font(14)
        cell.textLabel?.textColor = kMainColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        mjArr.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRow(at: indexPath, with: .automatic)
        tableView.endUpdates()
    }
    
    
}
