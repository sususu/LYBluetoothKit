//
//  DeviceTestCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/15.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol DeviceTestCellDelegate: NSObjectProtocol {
    func dtcAddLog(log: String);
    func dtcShowAlert(title: String?, msg: String);
}


class DeviceTestCell: UITableViewCell {

    var nameBtn: UIButton!
    
    var paramViews: UIView!
    
    var proto: Protocol!
    
    var delegate: DeviceTestCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createViews()
    }
    
    func createViews() {
        nameBtn = UIButton(type: .custom)
        nameBtn.frame = CGRect(x: 20, y: 5, width: 100, height: 30)
        nameBtn.backgroundColor = kMainColor
        nameBtn.addTarget(self, action: #selector(nameBtnClick), for: .touchUpInside)
        nameBtn.titleLabel?.font = bFont(12)
        nameBtn.layer.cornerRadius = 3
        nameBtn.layer.masksToBounds = true
        contentView.addSubview(nameBtn)
        
        paramViews = UIView(frame: CGRect(x: nameBtn.right + 10, y: 5, width: kScreenWidth - nameBtn.right - 10 - 20, height: 30))
        contentView.addSubview(paramViews)
    }
    
    func updateUI(withProtocol proto: Protocol) {
        
        self.proto = proto
        
        paramViews.removeAllSubviews()
        nameBtn.setTitle(proto.name, for: .normal)
        let nameSize = proto.name.size(withFont: nameBtn.titleLabel!.font)
        if (nameSize.width + 20) > 100 {
            nameBtn.width = nameSize.width + 20
            
            paramViews.frame = CGRect(x: nameBtn.right + 10, y: 5, width: kScreenWidth - nameBtn.right - 10 - 20, height: 30)
        }
        
        guard let units = proto.paramUnits else {
            return
        }
        var x:CGFloat = 0
        let w:CGFloat = 100, h = paramViews.height
        for unit in units {
            let tf = UITextField(frame: CGRect(x: x, y: 0, width: w, height: h))
            tf.font = bFont(13)
            tf.borderStyle = .roundedRect
            tf.text = unit.param!.value
            if unit.param!.type == .int {
                tf.keyboardType = .namePhonePad
            }
            paramViews.addSubview(tf)
            x += tf.width + 10
        }
    }
    
    @objc func nameBtnClick() {
        if let units = proto.paramUnits {
            
            let svs = paramViews.subviews
            if svs.count == units.count {
                for i in 0 ..< svs.count {
                    let tf = svs[i] as! UITextField
                    let unit = units[i]
                    unit.param!.value = tf.text
                }
            }
        }
        
        let runner = ProtocolRunner()
        
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            self.delegate?.dtcAddLog(log: str)
//            weakSelf?.resultStr = str
//            weakSelf?.excuteFinish(resultStr: str)
        }, stringCallback: { (str) in
            let result = "返回：" + str
//            weakSelf?.resultStr = str
//            weakSelf?.excuteFinish(resultStr: result)
            self.delegate?.dtcAddLog(log: result)
        }, dictCallback: { (dict) in
            
        }, dictArrayCallback: { (dictArr) in
            
        }) { (error) in
//            weakSelf?.excuteFinish(resultStr: "错误：" + (weakSelf?.errorMsgFromBleError(error) ?? ""))
            self.delegate?.dtcAddLog(log: "错误：" + self.errorMsgFromBleError(error))
        }
        
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
        return ""
    }
}
