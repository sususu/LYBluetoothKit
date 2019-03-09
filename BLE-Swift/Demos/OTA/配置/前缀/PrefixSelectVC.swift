//
//  PrefixSelectVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol PrefixSelectVCDelegate: NSObjectProtocol {
    func didSelectPrefixStr(prefixStr: String, bleName: String);
}


class PrefixSelectVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, PrefixAddVCDelegate, UIDocumentInteractionControllerDelegate {

    var prefixs: [OtaPrefix]!
    
    weak var delegate: PrefixSelectVCDelegate?
    
    var docController: UIDocumentInteractionController?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if OtaService.shared.prefixs.count == 0 {
            prefixs = OtaService.shared.readPrefixsFromDisk()
            OtaService.shared.prefixs = prefixs
        } else {
            prefixs = OtaService.shared.prefixs
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true
        tableView.register(UINib(nibName: "PrefixCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        title = TR("OTA蓝牙前缀")
        
        setNavRightButton(text: TR("EDIT"), sel: #selector(editBtnClick))
    }


    // MARK: - 事件处理
    @IBAction func addNewItem(_ sender: Any) {
        let vc = PrefixAddVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func exportAllItems(_ sender: Any) {
        
        let data = try! JSONEncoder().encode(prefixs)
        
        guard let url = StorageUtils.saveAsFile(forData: data, fileName: "BLE-Appscomm_Prefixs.json") else {
            showError(TR("Save as file failed"))
            return
        }
        if docController == nil {
            docController = UIDocumentInteractionController(url: url)
        }
        docController!.delegate = self
        docController?.name = "BLE-Appscomm_Prefixs.json"
        
        docController!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
    }
    
    @objc func editBtnClick() {
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
            setNavRightButton(text: TR("EDIT"), sel: #selector(editBtnClick))
            OtaService.shared.prefixs = prefixs
            OtaService.shared.savePrefixsToDisk()
        } else {
            self.tableView.setEditing(true, animated: true)
            setNavRightButton(text: "完成", sel: #selector(editBtnClick))
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tmp = prefixs[sourceIndexPath.row]
        prefixs[sourceIndexPath.row] = prefixs[destinationIndexPath.row]
        prefixs[destinationIndexPath.row] = tmp
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let rowActions = [
            UITableViewRowAction(style: .destructive, title: "删除", handler: { (action, indexPath) in
                self.deletePrefix(atIndexPath: indexPath)
            }),
            UITableViewRowAction(style: .normal, title: "编辑", handler: { (action, indexPath) in
                self.editPrefix(atIndexPath: indexPath)
            })
        ]
        return rowActions
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        deletePrefix(atIndexPath: indexPath)
    }
    
    private func deletePrefix(atIndexPath indexPath: IndexPath) {
        prefixs.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRow(at: indexPath, with: .automatic)
        tableView.endUpdates()
        OtaService.shared.prefixs = prefixs
        OtaService.shared.savePrefixsToDisk()
    }
    
    private func editPrefix(atIndexPath indexPath: IndexPath) {
        let vc = PrefixAddVC()
        vc.prefix = prefixs[indexPath.row]
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prefixs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! PrefixCell
        cell.updateUI(withPrefix: prefixs[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.isEditing {
            editPrefix(atIndexPath: indexPath)
        } else {
            delegate?.didSelectPrefixStr(prefixStr: prefixs[indexPath.row].prefix, bleName: prefixs[indexPath.row].bleName)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TR("Product List")
    }
    
    // MARK: - 代理
    func didSavePrefix(prefix: OtaPrefix) {
        if OtaService.shared.prefixs.count == 0 {
            prefixs = OtaService.shared.readPrefixsFromDisk()
            OtaService.shared.prefixs = prefixs
        } else {
            prefixs = OtaService.shared.prefixs
        }
        tableView.reloadData()
    }
}
