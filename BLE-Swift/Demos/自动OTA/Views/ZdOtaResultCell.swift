//
//  ZdOtaResultCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ZdOtaResultCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var durationLbl: UILabel!
    
    @IBOutlet weak var resetLbl: UILabel!
    
    func updateUI(withTask task: ZdOtaTask, isSuccess: Bool) {
        nameLbl.text = task.name
        
        if isSuccess {
            durationLbl.textColor = tmpTextColor
            let second = Int(task.endTime - task.startTime)
            durationLbl.text = "耗时：\(second)秒"
            resetLbl.text = task.hadResetDevice ? "已重置" : "未重置"
            if task.hadResetDevice {
                resetLbl.textColor = rgb(30, 200, 30)
            } else {
                resetLbl.textColor = rgb(200, 30, 30)
            }
        } else {
            durationLbl.textColor = rgb(200, 30, 30)
            durationLbl.text = errorMsgFromBleError(task.error)
            resetLbl.text = ""
        }
    }
    
    var tmpTextColor: UIColor!
    override func awakeFromNib() {
        super.awakeFromNib()
        tmpTextColor = durationLbl.textColor
    }

    
    func errorMsgFromBleError(_ error: BLEError?) -> String {
        guard let err = error else {
            return TR("Cool")
        }
        switch err {
        case .phoneError(let reason):
            if case .bluetoothPowerOff = reason {
                return TR("Please turn on bluetooth")
            } else {
                return TR("Bluetooth is still unavailable")
            }
        case .deviceError(let reason):
            switch reason {
            case .disconnected:
                return TR("Bluetooth is disconnected")
            case .noServices:
                return TR("No services found on devices")
            default:
                break
            }
        case .taskError(let reason):
            switch reason {
            case .timeout:
                return TR("Timeout")
            case .sendFailed:
                return TR("Failed")
            case .paramsError:
                return TR("Params error")
            case .dataError:
                return TR("Data error")
            case .repeatTask:
                return TR("Task repeated")
            case .cancel:
                return TR("Task cancel")
            }
        }
        return "未知错误"
    }
}
