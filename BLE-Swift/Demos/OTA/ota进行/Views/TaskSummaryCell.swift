//
//  TaskSummaryCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TaskSummaryCell: UICollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var progressLbl: UILabel!
    
    var task: OtaTask!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNormalTintColor()
        addObserver()
    }
    
    func updateCell(withTask task: OtaTask) {
        self.task = task
        updateUI()
    }
    
    private func updateUI() {
        nameLbl.text = task.config?.deviceName
        if task.state == .otaing {
            setNormalTintColor()
            progressView.progress = task.progress
            progressLbl.text = "\(Int(task.progress * 100))%"
        }
        else if task.state == .failed {
            setFailedTintColor()
            progressView.progress = 1
            progressLbl.text = TR("Failed")
        }
        else if task.state == .finish {
            setSuccessTintColor()
            progressView.progress = task.progress
            progressLbl.text = TR("Success")
        }
        else {
            setNormalTintColor()
            progressView.progress = 0
            progressLbl.text = TR("Not Ready")
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
        self.progressLbl.textColor = kMainColor
    }
    
    private func setFailedTintColor() {
        self.progressView.progressTintColor = rgb(200, 30, 30)
        self.progressLbl.textColor = rgb(200, 30, 30)
    }
    
    private func setSuccessTintColor() {
        self.progressView.progressTintColor = rgb(30, 200, 30)
        self.progressLbl.textColor = rgb(30, 200, 30)
    }
    
}
