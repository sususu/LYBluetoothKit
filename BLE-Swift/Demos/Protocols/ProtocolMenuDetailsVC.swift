//
//  ProtocolMenuDetailsVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolMenuDetailsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, AddProtocolVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var menu: ProtocolMenu
    
    var runner = ProtocolRunner()
    
    
    init(menu: ProtocolMenu) {
        self.menu = menu
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProtocolMenuDetailCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 45
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 80))
        
        self.title = menu.name
        
        setNavRightButton(text: TR("添加"), sel: #selector(addBtnClick(_:)))
    }


    // MARK: - 事件处理
    @IBAction func addBtnClick(_ sender: Any) {
        let vc = AddProtocolVC()
        vc.menu = menu
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 代理
    func didAddNewProtocol(protocol: Protocol) {
        tableView.reloadData()
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.protocols.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ProtocolMenuDetailCell
        cell.updateUI(withProtocol: self.menu.protocols[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        weak var weakSelf = self
        runner.run(self.menu.protocols[indexPath.row], boolCallback: { (bool) in
            
        }, stringCallback: { (str) in
            weakSelf?.alert(msg: (str ?? ""), confirmSel: nil, cancelText: nil, cancelSel: nil)
        }, dictCallback: { (dict) in
            
        }, dictArrayCallback: { (dicts) in
            
        }) { (err) in
            weakSelf?.handleBleError(error: err)
        }
 */
        let vc = ProtocolExcuteVC()
        vc.proto = menu.protocols[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.menu.protocols.remove(at: indexPath.row)
            ProtocolService.shared.saveMenus()
            self.tableView.reloadData()
            self.showSuccess(TR("Success"))
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
        
    }
    
}
