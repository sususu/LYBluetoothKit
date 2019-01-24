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


class PrefixSelectVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, PrefixAddVCDelegate {

    var prefixs: [OtaPrefix]!
    
    weak var delegate: PrefixSelectVCDelegate?
    
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
        tableView.register(UINib(nibName: "PrefixCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        title = TR("OTA prefix")
        
        setNavRightButton(text: TR("EDIT"), sel: #selector(editBtnClick))
    }


    // MARK: - 事件处理
    @IBAction func addNewItem(_ sender: Any) {
        let vc = PrefixAddVC()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func exportAllItems(_ sender: Any) {
        
    }
    
    @objc func editBtnClick() {
        
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
        delegate?.didSelectPrefixStr(prefixStr: prefixs[indexPath.row].prefix, bleName: prefixs[indexPath.row].bleName)
        navigationController?.popViewController(animated: true)
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
