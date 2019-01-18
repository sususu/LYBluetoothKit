//
//  TaskDetailCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TaskDetailCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLbl: UILabel!
    
    var task: OtaTask!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNormalTintColor()
        addObserver()
        progressView.layer.cornerRadius = 5
        progressView.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.layer.cornerRadius = progressView.bounds.height / 2
        progressView.layer.masksToBounds = true
        progressView.progressTintColor = kMainColor
        
        progressLbl.layer.cornerRadius = progressLbl.bounds.height / 2
        progressLbl.layer.masksToBounds = true
    }
    
    func updateUI(withTask task: OtaTask) {
        self.task = task
        
        updateUI()
    }
    
    func updateUI() {
        
        let deviceName = task.config?.deviceName ?? ""
        
        if deviceName == task.device.name {
            nameLbl.attributedText = nil
            nameLbl.text = task.device.name
        } else {
            nameLbl.text = nil
            
            let str2 = "(" + task.device.name + ")"
            let attrStr = NSMutableAttributedString(string: deviceName + str2)
            
            attrStr.addAttribute(.foregroundColor, value: nameLbl.textColor, range: NSRange(location: 0, length: deviceName.count))
            attrStr.addAttribute(.font, value: nameLbl.font, range: NSRange(location: 0, length: deviceName.count))
            attrStr.addAttribute(.foregroundColor, value: rgb(180, 30, 30), range: NSRange(location: deviceName.count, length: str2.count))
            let f = bFont(14)
            attrStr.addAttribute(.font, value: f, range: NSRange(location: deviceName.count, length: str2.count))
            nameLbl.attributedText = attrStr
        }

        if task.state == .otaing {
            setNormalTintColor()
            progressView.progress = task.progress
            progressLbl.text = "\(Int(task.progress * 100))%"
        }
        else if task.state == .failed {
            setFailedTintColor()
            progressView.progress = 1
            progressLbl.text = "0"
        }
        else if task.state == .finish {
            setSuccessTintColor()
            progressView.progress = task.progress
            progressLbl.text = "100%"
        }
        else {
            setNormalTintColor()
            progressView.progress = 0
            progressLbl.text = ""
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(otaFailedNotification(notification:)), name: kOtaTaskFailedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otaFinishNotification(notification:)), name: kOtaTaskFinishNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otaProgressNotification(notification:)), name: kOtaTaskProgressUpdateNotification, object: nil)
    }
    
    
    @objc func otaFailedNotification(notification: Notification) {
        updateUI()
    }
    @objc func otaFinishNotification(notification: Notification) {
        updateUI()
    }
    @objc func otaProgressNotification(notification: Notification) {
        updateUI()
    }
    
    private func setNormalTintColor() {
        self.progressView.progressTintColor = kMainColor
        self.progressLbl.backgroundColor = kMainColor
    }
    
    private func setFailedTintColor() {
        self.progressView.progressTintColor = rgb(200, 30, 30)
        self.progressLbl.backgroundColor = rgb(200, 30, 30)
    }
    
    private func setSuccessTintColor() {
        self.progressView.progressTintColor = rgb(30, 200, 30)
        self.progressLbl.backgroundColor = rgb(30, 200, 30)
    }
}
