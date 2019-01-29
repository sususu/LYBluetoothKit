//
//  DeviceResponseLogView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/26.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class DeviceResponseLogView: UIView {

    private var kMinSize = CGSize(width: kScreenWidth, height: kScreenWidth * 0.6)
    
    private var logText: String = ""
    
    var textView: UITextView!
    var headerView: UIView!
    var contentView: UIView!
    
    var dragView: UILabel!
    var clearBtn: UIButton!
    var hiddenBtn: UIButton!
    var fullBtn: UIButton!
    
    static var shared: DeviceResponseLogView?
    
    static func create() {
        let kMinSize = CGSize(width: kScreenWidth, height: kScreenWidth * 0.6)
        shared = DeviceResponseLogView(frame: CGRect(origin: CGPoint(x: 0, y: kStatusBarHeight), size: kMinSize))
        UIApplication.shared.keyWindow?.addSubview(shared!)
        shared?.isHidden = true
    }
    
    static func destroy() {
        shared?.removeFromSuperview()
        shared = nil
    }
    
    static func show() {
        shared?.isHidden = false
    }
    
    static func printLog(log: String) {
        shared?.addLog(log: log)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = rgb(50, 50, 50)
        
        headerView = UIView(frame: CGRect.zero)
        addSubview(headerView)
        
        dragView = UILabel(frame: CGRect.zero)
        dragView.font = font(12)
        dragView.text = "拖我"
        dragView.textColor = UIColor.white
        dragView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(drag(gesture:)))
        dragView.addGestureRecognizer(pan)
        headerView.addSubview(dragView)
        
        clearBtn = UIButton(type: .custom)
        clearBtn.setTitle("清除", for: .normal)
        clearBtn.addTarget(self, action: #selector(clearBtnClick), for: .touchUpInside)
        clearBtn.titleLabel?.font = font(12)
        headerView.addSubview(clearBtn)
        
        hiddenBtn = UIButton(type: .custom)
        hiddenBtn.setTitle("隐藏", for: .normal)
        hiddenBtn.addTarget(self, action: #selector(hideBtnClick), for: .touchUpInside)
        hiddenBtn.titleLabel?.font = font(12)
        headerView.addSubview(hiddenBtn)
     
        fullBtn = UIButton(type: .custom)
        fullBtn.setTitle("全屏", for: .normal)
        fullBtn.setTitle("缩小", for: .selected)
        fullBtn.addTarget(self, action: #selector(fullOrNormalScreenClick), for: .touchUpInside)
        fullBtn.titleLabel?.font = font(12)
        headerView.addSubview(fullBtn)
        
        contentView = UIView(frame: CGRect.zero)
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)
        
        textView = UITextView(frame: CGRect.zero)
        textView.font = font(12)
        textView.textColor = rgb(20, 220, 20)
        textView.backgroundColor = UIColor.clear
        contentView.addSubview(textView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let btnWidth: CGFloat = 50
        let headerHeight: CGFloat = 40
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.width, height: 40)
        dragView.frame = CGRect(x: 5, y: 0, width: btnWidth, height: headerView.height)
        
        fullBtn.frame = CGRect(x: headerView.width - btnWidth - 5, y: 0, width: btnWidth, height: headerHeight)
        
        hiddenBtn.frame = CGRect(x: fullBtn.left - btnWidth - 5, y: 0, width: btnWidth, height: headerHeight)
        
        clearBtn.frame = CGRect(x: hiddenBtn.left - btnWidth - 5, y: 0, width: btnWidth, height: headerHeight)
        
        contentView.frame = CGRect(x: 0, y: headerView.bottom, width: self.width, height: self.height - headerView.bottom)
        textView.frame = contentView.bounds
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @objc func fullOrNormalScreenClick() {
        if fullBtn.isSelected {
            normalScreen()
        } else {
            fullScreen()
        }
        fullBtn.isSelected = !fullBtn.isSelected
    }
    
    @objc func fullScreen() {
        self.frame = CGRect(x: 0, y: kStatusBarHeight, width: kScreenWidth, height: kScreenHeight)
    }
    
    @objc func normalScreen() {
        self.frame = CGRect(origin: CGPoint(x: 0, y: kStatusBarHeight), size: kMinSize)
    }
    
    @objc func drag(gesture: UIGestureRecognizer) {
        
    }
    
    @objc func clearBtnClick() {
        logText = ""
        textView.text = ""
    }
    
    @objc func hideBtnClick() {
        DeviceResponseLogView.shared?.isHidden = true
    }
    
    func addLog(log: String) {
        logText += log + "\n"
        textView.text = logText
        textView.scrollRangeToVisible(NSMakeRange(logText.count - 1, 1))
    }
    
}
