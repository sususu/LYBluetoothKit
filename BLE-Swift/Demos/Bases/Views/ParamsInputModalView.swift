//
//  ParamsInputModalView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/6.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ParamsInputModalView: UIView, UITableViewDataSource, UITableViewDelegate {

    private static var sharedView: ParamsInputModalView?
    
    static func show(withStr: String, okCallback: ((Param)->Void)?, cancelCallback: (()->Void)?) {
        if let old = sharedView {
            old.removeFromSuperview()
        }
        sharedView = ParamsInputModalView(frame: UIScreen.main.bounds)
        sharedView?.valueStr = withStr
        sharedView?.setupViews()
        sharedView?.okCallback = okCallback
        sharedView?.cancelCallback = cancelCallback
        sharedView?.show()
    }
    
    static func setOldParam(_ oldParam: Param) {
        
        guard let sv = sharedView else {
            return
        }
        
        for tf in sv.tagTFs {
            tf.text = oldParam.label
        }
        if oldParam.type == .int {
            
        }
        else if oldParam.type == .enumeration {
            sv.paramSeg.selectedSegmentIndex = 1
            if let nameArr = oldParam.enumNameArr {
                sv.mjArr.removeAll()
                for i in 0 ..< nameArr.count {
                    sv.mjArr.append((nameArr[i], oldParam.enumValueArr![i]))
                }
            }
            sv.tableView?.reloadData()
        }
        else if oldParam.type == .time || oldParam.type == .date || oldParam.type == .datetime {
            sv.paramSeg.selectedSegmentIndex = 1
        }
        sv.segValueChanged(seg: sv.paramSeg)
    }
    
    private var timer: Timer!
    deinit {
        timer.invalidate()
    }
    
    private var valueStr: String!
    private var okCallback: ((Param)->Void)?
    private var cancelCallback: (()->Void)?
    
    private var contentView: UIView!
    
    private var paramSeg: UISegmentedControl!
    private var paramScrollView: UIScrollView!
    
    private func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    private func hide() {
        okCallback = nil
        cancelCallback = nil
        self.removeFromSuperview()
    }

    private func setupViews() {
        
        var offset:CGFloat = 80
        if kiPhoneX_S {
            offset = 160
        }
        
        backgroundColor = rgb(0, 0, 0, 0.8)
        contentView = UIView(frame: self.bounds.inset(by: UIEdgeInsets(top: offset, left: 15, bottom: offset, right: 15)))
        contentView.backgroundColor = rgb(240, 240, 240)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        
        
        var segTitles: [String] = []
        segTitles.append("普通数值")
        if valueStr.hasPrefix("Int") {
            if let len = Int(valueStr.suffix(1)) {
                if len == 1 || len == 2 {
                    segTitles.append("枚举")
                }
                else if len == 3 {
                    segTitles.append("时间")
                }
                else if len == 4 {
                    segTitles.append("日期")
                }
                else if len == 7 {
                    segTitles.append("日期时间")
                }
            }
        }
        
        let seg = UISegmentedControl(items: segTitles)
        seg.frame = CGRect(x: 5, y: 10, width: contentView.width - 10, height: 30)
        seg.tintColor = kMainColor
        seg.addTarget(self, action: #selector(segValueChanged(seg:)), for: .valueChanged)
        seg.selectedSegmentIndex = 0
        contentView.addSubview(seg)
        paramSeg = seg
        
        
        paramScrollView = UIScrollView(frame: CGRect(x: 5, y: seg.bottom + 5, width: seg.width, height: contentView.height - seg.bottom - 5 - 40))
        paramScrollView.isScrollEnabled = false
        contentView.addSubview(paramScrollView)
        paramScrollView.contentSize = CGSize(width: paramScrollView.width * CGFloat(segTitles.count), height: paramScrollView.height)
        createParamsView()
        
        
        let okBtn = UIButton(type: .custom)
        okBtn.frame = CGRect(x: contentView.width - 80 - 5, y: contentView.height - 35, width: 80, height: 30)
        okBtn.backgroundColor = kMainColor
        okBtn.setTitle("确定", for: .normal)
        okBtn.layer.cornerRadius = 3
        okBtn.layer.masksToBounds = true
        okBtn.titleLabel?.font = font(14)
        okBtn.addTarget(self, action: #selector(okBtnClick), for: .touchUpInside)
        contentView.addSubview(okBtn)
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.frame = CGRect(x: okBtn.left - 80 - 10, y: contentView.height - 35, width: 80, height: 30)
        cancelBtn.backgroundColor = rgb(150, 40, 40)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.layer.masksToBounds = true
        cancelBtn.titleLabel?.font = font(14)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        contentView.addSubview(cancelBtn)
        
        
        timer = Timer(timeInterval: 1, target: self, selector: #selector(timeTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private var tagTFs: [UITextField] = []
    private var numberInputView: NumberInputView?
    private var datetimeLbl: UILabel?
    private var timeLbl: UILabel?
    private var dateLbl: UILabel?
    private var mjArr:[(String, Int)] = []
    private var tableView: UITableView?
    private var itemNameTF: UITextField!
    private var itemValueTF: NumberInputView!
    
    private func createParamsView() {
        tagTFs.removeAll()
        
        var x:CGFloat = 0, y:CGFloat = 10
        for i in 0 ..< paramSeg.numberOfSegments {
            x = CGFloat(i) * paramScrollView.width
            guard let title = paramSeg.titleForSegment(at: i) else {
                continue
            }
            
            let taglbl = UILabel(frame: CGRect(x: x, y: y, width: 80, height: 40))
            taglbl.font = font(14)
            taglbl.textColor = rgb(150, 150, 150)
            taglbl.text = "参数名称："
            taglbl.textAlignment = .center
            paramScrollView.addSubview(taglbl)
            
            let tagTF = UITextField(frame: CGRect(x: x + 85, y: y, width: paramScrollView.width - 85 - 5, height: 40))
            tagTF.font = font(16)
            tagTF.textColor = kMainColor
            tagTF.borderStyle = .roundedRect
            paramScrollView.addSubview(tagTF)
            tagTFs.append(tagTF)
            
            y += tagTF.height + 10
            if title == "普通数值" {
                numberInputView = NumberInputView(frame: CGRect(x: 5, y: y, width: paramScrollView.width - 10, height: 40))
                paramScrollView.addSubview(numberInputView!)
            }
            else if title == "枚举" {
                tableView = UITableView(frame: CGRect(x: x + 5, y: y, width: paramScrollView.width / 2, height: paramScrollView.height - y - 10), style: .plain)
                tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
                tableView?.dataSource = self
                tableView?.delegate = self
                tableView?.rowHeight = 30
                tableView?.layer.cornerRadius = 3
                tableView?.layer.masksToBounds = true
                paramScrollView.addSubview(tableView!)
                
                let left = tableView!.right + 5
                let width = paramScrollView.width / 2 - 5 - 5 - 5
                itemNameTF = UITextField(frame: CGRect(x: left, y: y, width: width, height: 30))
                itemNameTF.font = font(12)
                itemNameTF.textColor = kMainColor
                itemNameTF.placeholder = "项目名称"
                itemNameTF.textAlignment = .center
                itemNameTF.borderStyle = .roundedRect
                paramScrollView.addSubview(itemNameTF)
                
                itemValueTF = NumberInputView(frame: CGRect(x: left, y: itemNameTF.bottom + 5, width: width, height: 30))
                paramScrollView.addSubview(itemValueTF)
                
                let addItemBtn = UIButton(type: .custom)
                addItemBtn.frame = CGRect(x: left, y: itemValueTF.bottom + 5, width: width, height: 30)
                addItemBtn.backgroundColor = kMainColor
                addItemBtn.layer.cornerRadius = 3
                addItemBtn.layer.masksToBounds = true
                addItemBtn.addTarget(self, action: #selector(addItemBtnClick), for: .touchUpInside)
                addItemBtn.setTitle("保存项目", for: .normal)
                addItemBtn.titleLabel?.font = font(12)
                paramScrollView.addSubview(addItemBtn)
            }
            else if title == "时间" {
                tagTF.text = "时间"
                timeLbl = UILabel(frame: CGRect(x: x, y: y, width: paramScrollView.width, height: 40))
                timeLbl?.textColor = kMainColor
                timeLbl?.font = font(16)
                timeLbl?.textAlignment = .center
                paramScrollView.addSubview(timeLbl!)
            }
            else if title == "日期" {
                tagTF.text = "日期"
                dateLbl = UILabel(frame: CGRect(x: x, y: y, width: paramScrollView.width, height: 40))
                dateLbl?.textColor = kMainColor
                dateLbl?.font = font(16)
                dateLbl?.textAlignment = .center
                paramScrollView.addSubview(dateLbl!)
            }
            else if title == "日期时间" {
                tagTF.text = "日期时间"
                datetimeLbl = UILabel(frame: CGRect(x: x, y: y, width: paramScrollView.width, height: 40))
                datetimeLbl?.textColor = kMainColor
                datetimeLbl?.font = font(16)
                datetimeLbl?.textAlignment = .center
                paramScrollView.addSubview(datetimeLbl!)
            }
            
            y = 10
        }
    }
    
    
    @objc private func okBtnClick() {
        
        let tagTF = tagTFs[paramSeg.selectedSegmentIndex]
        guard let label = tagTF.text, label.count > 0 else {
            return
        }
        
        guard let title = paramSeg.titleForSegment(at: paramSeg.selectedSegmentIndex) else {
            return
        }
        
        let p = Param(type: .int)
        p.label = label
        if title == "普通数值" {
            p.value = numberInputView?.textField.text
        }
        else if title == "枚举" {
            
            if mjArr.count == 0 {
                return
            }
            
            p.type = .enumeration
            p.enumNameArr = []
            p.enumValueArr = []
            for e in mjArr {
                p.enumNameArr?.append(e.0)
                p.enumValueArr?.append(e.1)
            }
            p.value = mjArr[0].0 + ":\(mjArr[0].1)"
        }
        else if title == "时间" {
            p.type = .time
            p.value = "time"
        }
        else if title == "日期" {
            p.type = .date
            p.value = "date"
        }
        else if title == "日期时间" {
            p.type = .datetime
            p.value = "datetime"
        }
        okCallback?(p)
        hide()
    }
    
    @objc private func cancelBtnClick() {
        hide()
        cancelCallback?()
    }
    
    @objc private func segValueChanged(seg: UISegmentedControl) {
        paramScrollView.setContentOffset(CGPoint(x: paramScrollView.width * CGFloat(seg.selectedSegmentIndex), y: 0), animated: true)
        paramScrollView.endEditing(true)
    }
    
    @objc private func addItemBtnClick() {
        guard let name = itemNameTF.text, name.count > 0 else {
            return
        }
        guard let num = Int(itemValueTF.textField.text ?? "") else {
            return
        }
        itemNameTF.text = ""
        itemValueTF.jiaBtnClick()
        mjArr.append((name, num))
        mjArr.sort { (e1, e2) -> Bool in
            return e1.1 < e2.1
        }
        tableView?.reloadData()
    }
    
    // MARK: - 定时器
    @objc private func timeTick() {
        let date = Date()
        
        let format = DateFormatter()
        format.dateFormat = "HH:mm:ss"
        timeLbl?.text = format.string(from: date)
        
        format.dateFormat = "yyyy-MM-dd"
        dateLbl?.text = format.string(from: date)
        
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        datetimeLbl?.text = format.string(from: date)
    }
    
    
    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mjArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = mjArr[indexPath.row].0 + ": \(mjArr[indexPath.row].1)"
        cell.textLabel?.font = font(12)
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
