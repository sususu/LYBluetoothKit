//
//  EnumSelectModalView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class EnumSelectModalView: UIView, UITableViewDataSource, UITableViewDelegate {

    private static var sharedView: EnumSelectModalView?

    static func show(withOkCallback okCallback: (((String, Int))->Void)?) {
        if let old = sharedView {
            old.removeFromSuperview()
        }
        sharedView = EnumSelectModalView(frame: UIScreen.main.bounds)
        sharedView?.setupViews()
        sharedView?.okCallback = okCallback
        sharedView?.show()
    }
    
    static func setOldParam(_ oldParam: Param) {
        
        guard let sv = sharedView else {
            return
        }
        
        sv.titleLbl.text = oldParam.label
        
        if let nameArr = oldParam.enumNameArr {
            sv.mjArr.removeAll()
            for i in 0 ..< nameArr.count {
                sv.mjArr.append((nameArr[i], oldParam.enumValueArr![i]))
            }
        }
        sv.tableView?.reloadData()
    }
    
    private var okCallback: (((String, Int))->Void)?
    
    private var contentView: UIView!
    
    private var titleLbl: UILabel!
    private var tableView: UITableView!
    private var mjArr:[(String, Int)] = []
    
    private func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    private func hide() {
        okCallback = nil
        self.removeFromSuperview()
    }
    
    private func setupViews() {
        
        backgroundColor = rgb(0, 0, 0, 0.8)
        
        var offset:CGFloat = 120
        if kiPhoneX_S {
            offset = 200
        }
        
        contentView = UIView(frame: self.bounds.inset(by: UIEdgeInsets(top: offset, left: 40, bottom: offset, right: 40)))
        contentView.backgroundColor = rgb(240, 240, 240)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        
        titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: contentView.width, height: 40))
        titleLbl.backgroundColor = rgb(240, 240, 240)
        titleLbl.textColor = rgb(240, 60, 60)
        titleLbl.font = bFont(16)
        titleLbl.textAlignment = .center
        contentView.addSubview(titleLbl)
        
        tableView = UITableView(frame: contentView.bounds.inset(by: UIEdgeInsets(top: titleLbl.height, left: 0, bottom: 0, right: 0)), style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.layer.cornerRadius = 3
        tableView.layer.masksToBounds = true
        contentView.addSubview(tableView!)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selfClick))
        addGestureRecognizer(tap)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        okCallback?(mjArr[indexPath.row])
        hide()
    }
    
    
    @objc func selfClick() {
        hide()
    }
}
