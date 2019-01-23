//
//  FirmwareSelectVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol FirmwareSelectVCDelegate : NSObjectProtocol {
    func didSelectFirmware(firmware: Firmware?, selectType: OtaDataType);
    func didSelectFirmwares(firmwares: [Firmware]?, selectType: OtaDataType);
}

class FirmwareSelectVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FirmwareSelectVCDelegate?
    
    var selectType: OtaDataType!
    var firmwares: [Firmware] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for fm in OtaService.shared.firmwares {
            if fm.type == selectType {
                firmwares.append(fm)
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FirmwareSelectCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
        
        if selectType == .picture  {
            tableView.allowsMultipleSelection = true
        }
        
        title = TR("Firmwares")
        setNavRightButton(text: TR("DONE"), sel: #selector(doneBtnClick))
    }
    
    // MARK: - 事件处理
    @objc func doneBtnClick() {
        if selectType != OtaDataType.picture {
            delegate?.didSelectFirmware(firmware: nil, selectType: selectType)
        } else {
            var firmwares: [Firmware]?
            if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 0 {
                firmwares = []
                for ip in indexPaths {
                    firmwares?.append(self.firmwares[ip.row])
                }
            }
            
            if firmwares != nil {
                firmwares?.sort(by: { (f1, f2) -> Bool in
                    return Float(f1.versionName) ?? 0 < Float(f2.versionName) ?? 0
                })
            }
            
            delegate?.didSelectFirmwares(firmwares: firmwares, selectType: selectType)
        }
        navigationController?.popViewController(animated: true)
    }
    

    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firmwares.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! FirmwareSelectCell
        cell.updateUI(withFirmware: firmwares[indexPath.row])
//        cell.accessoryType = .checkmark
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch selectType! {
        case .platform:
            return TR("Firmware List")
        case .touchPanel:
            return TR("TouchPanel List")
        case .heartRate:
            return TR("HeartRate List")
        case .picture:
            return TR("Picture List")
        case .freeScale:
            return TR("FressScale List")
        case .agps:
            return TR("Agps")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectType != OtaDataType.picture {
            delegate?.didSelectFirmware(firmware: self.firmwares[indexPath.row], selectType: selectType)
            navigationController?.popViewController(animated: true)
        }
    }
}
