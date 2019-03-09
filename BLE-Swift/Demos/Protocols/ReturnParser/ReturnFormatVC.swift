//
//  ReturnFormatVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/18.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol ReturnFormatVCDelegate: NSObjectProtocol {
    func cancelEditReturnFormat()
    func didFinishEditReturnFormat(format: ReturnFormat)
}

class ReturnFormatVC: BaseViewController, EnumManagerVCDelegate {

    var returnFormat: ReturnFormat!
    weak var delegate: ReturnFormatVCDelegate?
    
    var lineInputs = [SplitLineView]()
    var delBtns = [UIButton]()
    
    var addIntBtn: UIButton!
    var addStringBtn: UIButton!
    var addDateBtn: UIButton!
    var addEnumBtn: UIButton!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = returnFormat.typeName
        
        createViews()
        
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }

    func createViews() {
        
        let width = (kScreenWidth - 35) / 4
        
        addIntBtn = UIButton(type: .custom)
        addIntBtn.setTitle(TR("加一行(int)"), for: .normal)
        addIntBtn.backgroundColor = rgb(230, 100, 120)
        addIntBtn.titleLabel?.font = font(12)
        addIntBtn.frame = CGRect(x: 10, y: navigationBarHeight + 5, width: width, height: 30)
        addIntBtn.layer.cornerRadius = 4
        addIntBtn.layer.masksToBounds = true
        self.view.addSubview(addIntBtn)
        
        addDateBtn = UIButton(type: .custom)
        addDateBtn.setTitle(TR("加一行(日期)"), for: .normal)
        addDateBtn.backgroundColor = rgb(120, 230, 100)
        addDateBtn.titleLabel?.font = font(12)
        addDateBtn.frame = CGRect(x: addIntBtn.right + 5, y: navigationBarHeight + 5, width: width, height: 30)
        addDateBtn.layer.cornerRadius = 4
        addDateBtn.layer.masksToBounds = true
        self.view.addSubview(addDateBtn)
        
        addEnumBtn = UIButton(type: .custom)
        addEnumBtn.setTitle(TR("加一行(枚举)"), for: .normal)
        addEnumBtn.backgroundColor = rgb(100, 230, 200)
        addEnumBtn.titleLabel?.font = font(12)
        addEnumBtn.frame = CGRect(x: addDateBtn.right + 5, y: navigationBarHeight + 5, width: width, height: 30)
        addEnumBtn.layer.cornerRadius = 4
        addEnumBtn.layer.masksToBounds = true
        self.view.addSubview(addEnumBtn)
        
        addStringBtn = UIButton(type: .custom)
        addStringBtn.setTitle(TR("加一行(string)"), for: .normal)
        addStringBtn.backgroundColor = rgb(100, 120, 230)
        addStringBtn.titleLabel?.font = font(12)
        addStringBtn.frame = CGRect(x: addEnumBtn.right + 5, y: navigationBarHeight + 5, width: width, height: 30)
        addStringBtn.layer.cornerRadius = 4
        addStringBtn.layer.masksToBounds = true
        self.view.addSubview(addStringBtn)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: addIntBtn.bottom + 10, width: kScreenWidth, height: kScreenHeight - addIntBtn.bottom))
        self.view.addSubview(scrollView)
        
        addIntBtn.addTarget(self, action: #selector(createSplitLine), for: .touchUpInside)
        addDateBtn.addTarget(self, action: #selector(dateBtnClick), for: .touchUpInside)
        addEnumBtn.addTarget(self, action: #selector(enumBtnClick(btn:)), for: .touchUpInside)
        addStringBtn.addTarget(self, action: #selector(createSplitLine), for: .touchUpInside)
        createSplitLine(button: addIntBtn)
    }
    
    override func backBtnClick() {
        delegate?.cancelEditReturnFormat()
        super.backBtnClick()
    }
    
    @objc func saveBtnClick() {
        saveSplitLines()
    }
    
    func saveSplitLines() {
        if lineInputs.count == 0
        {
            showError(TR("空的，不能保存"))
            return
        }
        var expression = ""
        for i in 0 ..< lineInputs.count {
            let line = lineInputs[i]
            guard let name = line.name, name.count > 0 else {
                continue
            }
            if line.number == 0 {
                continue
            }
            // length-name,
            expression += "\(line.number)-\(name)-\(line.typeStr),"
            
        }
        
        if expression.count == 0 {
            showError(TR("请输入信息之后，再保存"))
            return
        }
        expression = String(expression.prefix(expression.count - 1))
        returnFormat.expression = expression
        returnFormat.ps = "length-name, length-name, ..."
        showSuccess(TR("Success"))
        delegate?.didFinishEditReturnFormat(format: returnFormat)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createSplitLine(button: UIButton) {
        
        var type: ParamType = .int
        if button == addStringBtn {
            type = .string
        }
        
        createLine(withType: type)
    }
    
    func createLine(withType type: ParamType, enumObj: EnumObj? = nil) {
        var y: CGFloat = 0
        if lineInputs.count > 0 {
            let line = lineInputs.last!
            y = line.bottom + 10
        }
        
        let x: CGFloat = 10
        let height: CGFloat = 40
        let width = kScreenWidth - 20 - 10 - height
        var line = SplitLineView(frame: CGRect(x: x, y: y, width: width, height: height), type: type)
        if enumObj != nil {
            line = SplitLineView(frame: CGRect(x: x, y: y, width: width, height: height), enumObj: enumObj!)
        }
        self.scrollView.addSubview(line)
        line.nameTF.becomeFirstResponder()
        lineInputs.append(line)
        
        let delBtn = UIButton(type: .custom)
        delBtn.setTitle(TR("删"), for: .normal)
        delBtn.backgroundColor = rgb(200, 30, 30)
        delBtn.titleLabel?.font = font(16)
        delBtn.frame = CGRect(x: line.right + 10, y: y, width: height, height: height)
        delBtn.addTarget(self, action: #selector(delBtnClick(btn:)), for: .touchUpInside)
        delBtn.tag = lineInputs.count - 1
        self.scrollView.addSubview(delBtn)
        delBtns.append(delBtn)
        
        scrollView.contentSize = CGSize(width: kScreenWidth, height: delBtn.bottom + 20)
    }
    
    
    @objc func dateBtnClick(btn:UIButton) {
        let sheet = UIAlertController(title: nil, message: "选择日期类型", preferredStyle: .actionSheet)
        let time = UIAlertAction(title: "时间", style: .default) { (action) in
            self.createLine(withType: .time)
        }
        let date = UIAlertAction(title: "日期", style: .default) { (action) in
            self.createLine(withType: .date)
        }
        let datetime = UIAlertAction(title: "日期时间", style: .default) { (action) in
            self.createLine(withType: .datetime)
        }
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: nil)
        sheet.addAction(time)
        sheet.addAction(date)
        sheet.addAction(datetime)
        sheet.addAction(cancel)
        self.navigationController?.present(sheet, animated: true, completion: nil)
    }
    
    @objc func enumBtnClick(btn: UIButton) {
        self.view.endEditing(true)
        let vc = EnumManagerVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func delBtnClick(btn: UIButton) {
        btn.removeFromSuperview()
        delBtns.remove(at: btn.tag)
        
        let line = lineInputs[btn.tag]
        line.removeFromSuperview()
        lineInputs.remove(at: btn.tag)
        
        fitFrameAfterDel(delIndex: btn.tag)
    }
    
    func fitFrameAfterDel(delIndex: Int) {
        var y: CGFloat = 20
        if delIndex > 0 {
            y = lineInputs[delIndex - 1].bottom + 10
        }
        for i in delIndex ..< lineInputs.count {
            let line = lineInputs[i]
            line.top = y
            delBtns[i].tag = i
            delBtns[i].top = y
            
            y = line.bottom + 10
        }
    }
    
    
    // MARK: - 代理实现
    func didSelect(enumObj: EnumObj) {
        createLine(withType: .enumeration, enumObj: enumObj)
    }
    
}
