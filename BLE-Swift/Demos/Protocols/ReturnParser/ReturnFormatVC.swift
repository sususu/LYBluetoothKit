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

class ReturnFormatVC: BaseViewController {

    var returnFormat: ReturnFormat!
    weak var delegate: ReturnFormatVCDelegate?
    
    var lineInputs = [SplitLineView]()
    var tlvInputs = [TlvLineView]()
    var delBtns = [UIButton]()
    
    var addIntBtn: UIButton!
    var addStringBtn: UIButton!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = returnFormat.typeName
        
        createViews()
        
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }

    func createViews() {
        
        let width = (kScreenWidth - 30) / 2
        
        addStringBtn = UIButton(type: .custom)
        addStringBtn.setTitle(TR("加一行(string)"), for: .normal)
        addStringBtn.backgroundColor = kMainColor
        addStringBtn.titleLabel?.font = font(14)
        addStringBtn.frame = CGRect(x: 10, y: navigationBarHeight + 5, width: width, height: 40)
        addStringBtn.layer.cornerRadius = 4
        addStringBtn.layer.masksToBounds = true
        self.view.addSubview(addStringBtn)
        
        addIntBtn = UIButton(type: .custom)
        addIntBtn.setTitle(TR("加一行(int)"), for: .normal)
        addIntBtn.backgroundColor = kMainColor
        addIntBtn.titleLabel?.font = font(14)
        addIntBtn.frame = CGRect(x: addStringBtn.right + 10, y: navigationBarHeight + 5, width: width, height: 40)
        addIntBtn.layer.cornerRadius = 4
        addIntBtn.layer.masksToBounds = true
        self.view.addSubview(addIntBtn)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: addIntBtn.bottom + 10, width: kScreenWidth, height: kScreenHeight - addIntBtn.bottom))
        self.view.addSubview(scrollView)
        
        if returnFormat.type == .split {
            addIntBtn.addTarget(self, action: #selector(createSplitLine), for: .touchUpInside)
            addStringBtn.addTarget(self, action: #selector(createSplitLine), for: .touchUpInside)
            createSplitLine(button: addIntBtn)
        } else {
            addIntBtn.addTarget(self, action: #selector(createTlvLine), for: .touchUpInside)
            addStringBtn.addTarget(self, action: #selector(createTlvLine), for: .touchUpInside)
            createTlvLine()
        }
    }
    
    override func backBtnClick() {
        delegate?.cancelEditReturnFormat()
        super.backBtnClick()
    }
    
    @objc func saveBtnClick() {
        if returnFormat.type == .split
        {
            saveSplitLines()
        }
        else
        {
            saveTlvLines()
        }
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
    
    func saveTlvLines() {
        
    }
    
    @objc func createSplitLine(button: UIButton) {
        var y: CGFloat = 0
        if lineInputs.count > 0 {
            let line = lineInputs.last!
            y = line.bottom + 10
        }
        
        var type: ParamType = .int
        if button == addStringBtn {
            type = .string
        }
        
        let x: CGFloat = 10
        let height: CGFloat = 40
        let width = kScreenWidth - 20 - 10 - height
        let line = SplitLineView(frame: CGRect(x: x, y: y, width: width, height: height), type: type)
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
    
    @objc func createTlvLine() {
        var y: CGFloat = 20
        if tlvInputs.count > 0 {
            let line = tlvInputs.last!
            y = line.bottom + 10
        }
        let x: CGFloat = 10
        let height: CGFloat = 40
        let width = kScreenWidth - 20 - 10 - height
        let line = TlvLineView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.scrollView.addSubview(line)
        tlvInputs.append(line)
        
        let delBtn = UIButton(type: .custom)
        delBtn.setTitle(TR("删"), for: .normal)
        delBtn.backgroundColor = rgb(200, 30, 30)
        delBtn.titleLabel?.font = font(16)
        delBtn.frame = CGRect(x: line.right + 10, y: y, width: height, height: height)
        delBtn.addTarget(self, action: #selector(delBtnClick(btn:)), for: .touchUpInside)
        delBtn.tag = tlvInputs.count - 1
        self.scrollView.addSubview(delBtn)
        delBtns.append(delBtn)
        
        scrollView.contentSize = CGSize(width: kScreenWidth, height: delBtn.bottom + 20)
    }
    
    
    @objc func delBtnClick(btn: UIButton) {
        btn.removeFromSuperview()
        delBtns.remove(at: btn.tag)
        
        if returnFormat.type == .split {
            let line = lineInputs[btn.tag]
            line.removeFromSuperview()
            lineInputs.remove(at: btn.tag)
        } else {
            let line = tlvInputs[btn.tag]
            line.removeFromSuperview()
            tlvInputs.remove(at: btn.tag)
        }
        
        fitFrameAfterDel(delIndex: btn.tag)
    }
    
    func fitFrameAfterDel(delIndex: Int) {
        if returnFormat.type == .split {
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
        } else {
            var y: CGFloat = 20
            if delIndex > 0 {
                y = tlvInputs[delIndex - 1].bottom + 10
            }
            for i in delIndex ..< tlvInputs.count {
                let line = tlvInputs[i]
                line.top = y
                delBtns[i].tag = i
                delBtns[i].top = y
                
                y = line.bottom + 10
            }
        }
    }
    
    
}
