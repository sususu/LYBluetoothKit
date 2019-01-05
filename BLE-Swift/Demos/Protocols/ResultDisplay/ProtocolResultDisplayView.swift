//
//  ProtocolResultDisplayView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ProtocolResultDisplayView: UIView, UITableViewDataSource, UITableViewDelegate {

    var contentView: UIView!
    var tableView: UITableView!
    
    var dicts: Array<Dictionary<String, Any>>!
    
    
    static func show(dict: Dictionary<String, Any>) {
        show(array: [dict])
    }

    static func show(array: Array<Dictionary<String, Any>>) {
        let displayView = ProtocolResultDisplayView(frame: UIScreen.main.bounds)
        displayView.dicts = array
        displayView.tableView.reloadData()
        UIApplication.shared.keyWindow?.addSubview(displayView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initViews() {
        
        self.backgroundColor = rgb(40, 40, 40, 0.8)
        
        let contentOffset: CGFloat = 60
        contentView = UIView(frame: CGRect(x: contentOffset, y: contentOffset, width: self.bounds.width - contentOffset * 2, height: self.bounds.height - contentOffset * 2))
        contentView.backgroundColor = rgb(200, 200, 200)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        
        
        
        let headerHeight: CGFloat = 44
        
        let headerLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: headerHeight))
        headerLbl.text = TR("Result Display")
        headerLbl.textColor = kMainColor
        headerLbl.font = font(20)
        addSubview(headerLbl)
        
        let bottomHeight: CGFloat = 44
        let middleHeight = contentView.bounds.height - headerHeight - bottomHeight
        
        tableView = UITableView(frame: CGRect(x: 0, y: headerLbl.bounds.height, width: contentView.bounds.width, height: middleHeight), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ResultDisplayCell", bundle: nil), forCellReuseIdentifier: "cellId")
        addSubview(tableView)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: headerHeight + middleHeight, width: contentView.bounds.width, height: bottomHeight))
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: bottomView.bounds.width - 80 - 10, y: 0, width: 80, height: bottomHeight)
        btn.setTitle(TR("OK"), for: .normal)
        btn.setTitleColor(kMainColor, for: .normal)
        btn.titleLabel?.font = font(16)
        btn.addTarget(self, action: #selector(okBtnClick), for: .touchUpInside)
        bottomView.addSubview(btn)
    }
    
    // MARK: - 事件处理
    @objc func okBtnClick() {
        removeFromSuperview()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ResultDisplayCell
        
        return cell
    }
    
}
