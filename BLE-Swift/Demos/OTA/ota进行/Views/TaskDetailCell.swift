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
        
        nameLbl.text = task.device.name
        
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
