//
//  FirmwareTypeVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol FirmwareTypeVCDelegate: NSObjectProtocol {
    func didFinishSelectType(type: OtaDataType)
}


class FirmwareTypeVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FirmwareTypeVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FirmwareTypeCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
        
        title = TR("Firmware Type")
    }
    
    // MARK: - 事件处理


    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FirmwareTypeCell
        cell.updateUI(withType: getDataType(forIndexPath: indexPath))
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = getDataType(forIndexPath: indexPath)
        delegate?.didFinishSelectType(type: type)
        navigationController?.popViewController(animated: true)
    }

    
    func getDataType(forIndexPath indexPath: IndexPath) -> OtaDataType {
        if indexPath.row == 0 {
            return .platform
        }
        else if indexPath.row == 1 {
            return .picture
        }
        else if indexPath.row == 2 {
            return .touchPanel
        }
        else if indexPath.row == 3 {
            return .heartRate
        }
        else if indexPath.row == 4 {
            return .freeScale
        }
        else {
            return .agps
        }
    }
    
    func getRow(forType type: OtaDataType) -> Int {
        if type == .platform {
            return 0
        }
        else if type == .picture {
            return 1
        }
        else if type == .touchPanel {
            return 2
        }
        else if type == .heartRate {
            return 3
        }
        else if type == .freeScale {
            return 4
        }
        else {
            return 5
        }
    }
    
}
