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
    var delegate: ReturnFormatVCDelegate?
    
    var lineInputs = [SplitLineView]()
    var delBtns = [UIButton]()
    
    var addLintBtn: UIButton!
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = returnFormat.typeName
        
        createViews()
        
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }

    func createViews() {
        addLintBtn = UIButton(type: .custom)
        addLintBtn.setTitle(TR("加一行"), for: .normal)
        addLintBtn.backgroundColor = kMainColor
        addLintBtn.titleLabel?.font = font(16)
        addLintBtn.frame = CGRect(x: 0, y: navigationBarHeight, width: kScreenWidth, height: 50)
        self.view.addSubview(addLintBtn)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: addLintBtn.bottom, width: kScreenWidth, height: kScreenHeight - addLintBtn.bottom))
        self.view.addSubview(scrollView)
        
        if returnFormat.type == .split {
            addLintBtn.addTarget(self, action: #selector(createSplitLine), for: .touchUpInside)
            createSplitLine()
        } else {
            addLintBtn.addTarget(self, action: #selector(createTlvLine), for: .touchUpInside)
            createTlvLine()
        }
    }
    
    @objc func saveBtnClick() {
        
    }
    
    
    @objc func createSplitLine() {
        var y: CGFloat = 20
        if lineInputs.count > 0 {
            let line = lineInputs.last!
            y = line.bottom + 10
        }
        let x: CGFloat = 10
        let height: CGFloat = 40
        let width = kScreenWidth - 20 - 10 - height
        let line = SplitLineView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.scrollView.addSubview(line)
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
        
    }
    
    
    @objc func delBtnClick(btn: UIButton) {
        btn.removeFromSuperview()
        delBtns.remove(at: btn.tag)
        
        if returnFormat.type == .split {
            let line = lineInputs[btn.tag]
            line.removeFromSuperview()
            lineInputs.remove(at: btn.tag)
        } else {
            
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
            
        }
    }
    
    
}
