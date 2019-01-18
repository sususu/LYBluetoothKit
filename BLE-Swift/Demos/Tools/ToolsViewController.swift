//
//  ToolsViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ToolsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIDocumentInteractionControllerDelegate {

    var products: [DeviceProduct]!
    
    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var docController: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = ToolsService.shared.products

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DeviceProductCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.rowHeight = 60
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 50))
        searchBar.delegate = self
        searchBar.placeholder = TR("Search by name")
        tableView.tableHeaderView = searchBar
        
        setNavLeftButton(text: TR("EXPORT"), sel: #selector(exportBtnClick))
        setNavRightButton(text: TR("ADD"), sel: #selector(addBtnClick))
    }
    
    
    // MARK: - 事件处理
    @objc func exportBtnClick() {
        openExporter()
    }
    
    
    @objc func addBtnClick() {
        let alert = UIAlertController(title: nil, message: TR("Please input name"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.createProduct(name: alert.textFields![0].text ?? "")
        }
        let cancel = UIAlertAction(title: TR("NO"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (tf) in
            tf.placeholder = TR("Product Name")
            tf.becomeFirstResponder()
        }
        navigationController?.present(alert, animated: true, completion: nil)
    }

    func createProduct(name: String) {
        if name.count == 0 {
            showError(TR("Please input name"))
            addBtnClick()
        } else {
            let ti = Date().timeIntervalSince1970
            let p = DeviceProduct(name: name, createTime: ti)
            ToolsService.shared.saveProduct(p)
            showSuccess(TR("Success"))
            products.insert(p, at: 0)
            tableView.reloadData()
        }
    }
    

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DeviceProductCell
        cell.updateUI(withProduct: products[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: TR("Are you to delete ?"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            ToolsService.shared.deleteProduct(self.products[indexPath.row])
            self.showSuccess(TR("Success"))
        }
        let cancel = UIAlertAction(title: TR("CANCEL"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DeviceTestVC()
        vc.product = products[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - 代理
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterProducts(withName: searchBar.text)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func filterProducts(withName name: String?) {
        guard let str = name, str.count > 0 else {
            products = ToolsService.shared.products
            tableView.reloadData()
            return
        }
        
        products = ToolsService.shared.products.filter({ (p) -> Bool in
            return p.name.contains(str)
        })
        tableView.reloadData()
        
    }
    
    
    // MARK: - 导出
    func openExporter() {
        
        guard let data = ToolsService.shared.getJsonData() else {
            showError(TR("Data error"))
            return
        }
        
        guard let url = StorageUtils.saveAsFile(forData: data, fileName: "DeviceProducts.json") else {
            showError(TR("Save as file failed"))
            return
        }
        if docController == nil {
            docController = UIDocumentInteractionController(url: url)
        }
        docController!.delegate = self
        docController?.name = "DeviceProducts.json"
        
        docController!.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        
    }
}
