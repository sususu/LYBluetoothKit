//
//  FirmwareManagerVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class FirmwareManagerVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    var firmwares: [Firmware] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firmwares = OtaService.shared.firmwares

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "FirmwareSelectCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 55
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            let fm = self.firmwares[indexPath.row]
            self.firmwares.remove(fm)
            OtaService.shared.deleteFirmware(fm)
            let path = StorageUtils.getDocPath().stringByAppending(pathComponent: fm.path)
            _ = StorageUtils.deleteFile(atPath: path)
            self.showSuccess(TR("Success"))
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
}
