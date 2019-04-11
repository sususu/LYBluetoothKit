//
//  DeviceTestFunctionCell.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol DeviceTestFunctionCellDelegate: NSObjectProtocol {
    func dtcAddLog(log: String);
    func dtcShowAlert(title: String?, msg: String);
}

class DeviceTestFunctionCell: UICollectionViewCell {
    
    var nameLbl: UILabel!
    
    var paramViews: UIView!
    
    var proto: Protocol!
    
    weak var delegate: DeviceTestFunctionCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        nameLbl = UILabel()
        nameLbl.backgroundColor = rgb(120, 120, 120)
        nameLbl.font = UIFont.systemFont(ofSize: 12)
        nameLbl.layer.cornerRadius = 3
        nameLbl.layer.masksToBounds = true
        nameLbl.textAlignment = .center
        nameLbl.textColor = UIColor.white
        contentView.addSubview(nameLbl)
        
        paramViews = UIView(frame: CGRect(x: nameLbl.right + 5, y: 5, width: 0, height: self.height))
        contentView.addSubview(paramViews)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var w = self.width
        if let units = proto.paramUnits, units.count > 0 {
            w -= 65
        }
        
        nameLbl.frame = CGRect(x: 0, y: 0, width: w, height: self.height)
        paramViews.frame = CGRect(x: nameLbl.right + 5, y: 0, width: 60, height: self.height)
        for v in paramViews.subviews {
            v.frame = paramViews.bounds
        }
    }
    
    func updateUI(withProtocol proto: Protocol) {
        
        self.proto = proto
        
        paramViews.removeAllSubviews()
        nameLbl.text = proto.name

        guard let units = proto.paramUnits else {
            return
        }
        let w:CGFloat = paramViews.width, h = paramViews.height
        for unit in units {
            let tf = UITextField(frame: CGRect(x: 0, y: 0, width: w, height: h))
            tf.font = bFont(13)
            tf.borderStyle = .roundedRect
            tf.text = unit.param!.value
            if unit.param!.type == .int {
                tf.keyboardType = .namePhonePad
            }
            paramViews.addSubview(tf)
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
        self.delegate?.dtcAddLog(log: "执行：\(proto.name)")
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
