//
//  ProtocolExcuteVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/26.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import YYKit

class ProtocolExcuteVC: BaseViewController {

    var proto: Protocol!
    
    var runner = ProtocolRunner()
    
    @IBOutlet weak var cmdTV: UITextView!
    
    var previewLbl: YYLabel!
    
    @IBOutlet weak var logTV: UITextView!
    
    @IBOutlet weak var countTF: UITextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var excuteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = proto.name
        
        showConnectState()
        
//        cmdTV.isUserInteractionEnabled = false
        previewLbl = YYLabel(frame: cmdTV.bounds)
        previewLbl.isUserInteractionEnabled = true
        previewLbl.numberOfLines = 0
        previewLbl.textVerticalAlignment = .top
        cmdTV.addSubview(previewLbl)
        
        reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLbl.frame = cmdTV.bounds
    }
    
    func reloadData() {
        
        var string = ""
        var startIndexs = [Int]()
        
        for unit in proto.cmdUnits {
            startIndexs.append(string.count)
            var str = ""
            let label = unit.param?.label ?? (unit.valueStr ?? "")
            if unit.param?.value != nil {
                str = "\(label)(\(unit.param!.value!))" + "  "
            } else {
                str = (label) + "  "
            }
            string += str
        }
        
        let attrStr = NSMutableAttributedString(string: string)
        attrStr.lineSpacing = 5
        attrStr.font = font(14)
        attrStr.color = kMainColor
        
        let markColor = UIColor.red
        
        for i in 0 ..< proto.cmdUnits.count {
            let unit = proto.cmdUnits[i]
            
            var str = ""
            let label = unit.param?.label ?? (unit.valueStr ?? "")
            if unit.param?.value != nil {
                str = "\(label)(\(unit.param!.value!))"
            } else {
                str = (label)
            }
            let range = NSRange(location: startIndexs[i], length: str.count)
            
            if unit.type == .variable {
                attrStr.setUnderlineStyle(.single, range: range)
                
                attrStr.setTextHighlight(range, color: markColor, backgroundColor: UIColor.clear) { (containerView, attrStr, range, rect) in
                    let str = attrStr.attributedSubstring(from: range).string
                    if str == "Len" {
                        self.alert(msg: "长度会自动生成", confirmText: "好的", confirmSel: nil, cancelText: nil, cancelSel: nil)
                    } else {
                        self.showDefaultValueInput(at: i)
                    }
                }
            }
            else {
                attrStr.setUnderlineStyle(.single, range: range)
                attrStr.setUnderlineColor(rgb(200, 200, 200), range: range)
            }
        }
        
        //        attrStr.setKern(NSNumber(value: 5), range: NSRange(location: 0, length: string.count))
        previewLbl.attributedText = attrStr
    }

    func showDefaultValueInput(at: Int) {
        let unit = proto.cmdUnits[at]
        guard let param = unit.param else {
            return
        }
        
        print("hello:\(unit.valueStr ?? "--")")
        let alert = UIAlertController(title: nil, message: "请输入参数值", preferredStyle: .alert)
        alert.addTextField { (textField) in
            if param.type == .int {
                textField.keyboardType = .numberPad
            }
        }
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            unit.param?.value = alert.textFields![0].text
            self.reloadData()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }

    // MARK: - 事件处理
    
    @objc func editBtnClick() {
        
    }
    
    @IBAction func excuteBtnClick(_ sender: Any) {
        
        let countStr = countTF.text ?? "1"
        // 默认0
        proto.returnCount = Int(countStr) ?? 1
        
        printLog("发送：" + (runner.getCmdData(pcl: proto)?.hexEncodedString() ?? ""))
        
        weak var weakSelf = self
        
        excuteBtn.isEnabled = false
        
        runner.run(proto, boolCallback: { (bool) in
            let str = bool ? "成功" : "失败"
            weakSelf?.resultStr = str
            weakSelf?.excuteFinish(resultStr: str)
        }, stringCallback: { (str) in
            let result = "返回：" + str
            weakSelf?.resultStr = str
            weakSelf?.excuteFinish(resultStr: result)
        }, dictCallback: { (dict) in
            let result = weakSelf?.getJSONStringFromDictionary(dictionary: dict)
            weakSelf?.resultStr = result
            weakSelf?.excuteFinish(resultStr: result)
        }, dictArrayCallback: { (dictArr) in
            let result = weakSelf?.getJSONStringFromArray(array: dictArr)
            weakSelf?.resultStr = result
            weakSelf?.excuteFinish(resultStr: result)
        }) { (error) in
            weakSelf?.excuteFinish(resultStr: "错误：" + (weakSelf?.errorMsgFromBleError(error) ?? ""))
        }
        
    }
    
    func getJSONStringFromDictionary(dictionary:Dictionary<String, Any>) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        return String(bytes: data ?? Data(), encoding: .utf8) ?? "";
    }
    
    //数组转json
    func getJSONStringFromArray(array:Array<Dictionary<String, Any>>) -> String {
        
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data = try? JSONSerialization.data(withJSONObject: array, options: [])
        let JSONString = String(bytes:data ?? Data(), encoding: .utf8) ?? ""
        return JSONString
        
    }
    
    
    func excuteFinish(resultStr: String?) {
        excuteBtn.isEnabled = true
        guard let msg = resultStr else {
            return
        }
        printLog(msg)
    }
    
    
    private var resultStr: String?
    @IBAction func copyResultBtnClick(_ sender: Any) {
        UIPasteboard.general.string = resultStr
    }
    
    @IBAction func copyBtnClick(_ sender: Any) {
        UIPasteboard.general.string = logTV.text
    }
    
    @IBAction func clearBtnClick(_ sender: Any) {
        logStr = ""
        logLine = 1
        logTV.text = ""
    }
    
    @IBAction func selectBtnClick(_ sender: Any) {
    }
    
    // 日志
    private var logStr = ""
    private var logLine = 1
    private func printLog(_ log: String) {
        logStr += "\(logLine). " + log + "\n"
        logTV.text = logStr
        logLine += 1
        logTV.scrollRangeToVisible(NSMakeRange(logStr.count - 1, 1))
    }
}
