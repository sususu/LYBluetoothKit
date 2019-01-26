//
//  AddProtocolVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import YYKit
import DLRadioButton

protocol AddProtocolVCDelegate: NSObjectProtocol {
    func didAddNewProtocol(protocol: Protocol)
}


class AddProtocolVC: BaseViewController, ReturnFormatVCDelegate, CmdInputViewDelegate {

    @IBOutlet weak var cmdInputView: CmdInputView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var expressionLbl: UILabel!
    
    @IBOutlet weak var boolRadio: DLRadioButton!
    
    @IBOutlet weak var stringRadio: DLRadioButton!
    
    @IBOutlet weak var splitRadio: DLRadioButton!
    
    @IBOutlet weak var tlvRadio: DLRadioButton!
    
    @IBOutlet weak var customRadio: DLRadioButton!
    
    weak var delegate: AddProtocolVCDelegate?
    
    var previewLbl: YYLabel!
    @IBOutlet weak var psLbl: UILabel!
    
    var menu: ProtocolMenu!
    
    var returnFormat = boolReturnFormat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        previewLbl = YYLabel(frame: previewView.bounds)
        previewLbl.isUserInteractionEnabled = true
        previewLbl.numberOfLines = 0
        previewLbl.textVerticalAlignment = .top
        previewView.addSubview(previewLbl)
        
        cmdInputView.delegate = self
        
        boolRadio.isSelected = true
        boolRadio.otherButtons = [stringRadio, splitRadio, tlvRadio, customRadio]

        self.title = TR("添加协议")
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }


    // MARK: - 事件处理
    @objc func saveBtnClick() {
        if cmdInputView.units.count == 0 {
            showError(TR("请输入指令"))
            return
        }
        
        guard let name = nameTF.text, name.count > 0 else {
            showError(TR("请输入名称"))
            return
        }
        
        let proto = Protocol()
        proto.name = name
        proto.cmdUnits = cmdInputView.units
        proto.returnFormat = returnFormat
        
        menu.protocols.insert(proto, at: 0)
        
        ProtocolService.shared.saveMenus()
        
        showSuccess(TR("Success"))
        
        delegate?.didAddNewProtocol(protocol: proto)
        
        navigationController?.popViewController(animated: true)
    }

    @IBAction func boolBtnClick(_ sender: Any) {
        returnFormat = boolReturnFormat()
        cancelEditReturnFormat()
    }
    
    @IBAction func stringBtnClick(_ sender: Any) {
        returnFormat = stringReturnFormat()
        cancelEditReturnFormat()
    }
    
    
    @IBAction func splitBtnClick(_ sender: Any) {
        let vc = ReturnFormatVC()
        vc.returnFormat = splitReturnFormat()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func tlvBtnClick(_ sender: Any) {
        let vc = ReturnFormatVC()
        vc.returnFormat = tlvReturnFormat()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func customBtnClick(_ sender: Any) {
    }
    
    
    // MARK: - Delegate
    func didFinishEditing() {
        
        var string = ""
        
        var startIndexs = [Int]()
        
        for unit in cmdInputView.units {
            startIndexs.append(string.count)
            var str = ""
            if unit.param?.value != nil {
                str = "\(unit.valueStr ?? "")(\(unit.param!.value!))" + "  "
            } else {
                str = (unit.valueStr ?? "") + "  "
            }
            string += str
        }
        
        let attrStr = NSMutableAttributedString(string: string)
        attrStr.lineSpacing = 5
        attrStr.font = font(14)
        attrStr.color = kMainColor
        
        let markColor = UIColor.red
        
        for i in 0 ..< cmdInputView.units.count {
            let unit = cmdInputView.units[i]
            
            var str = ""
            if unit.param?.value != nil {
                str = "\(unit.valueStr ?? "")(\(unit.param!.value!))"
            } else {
                str = (unit.valueStr ?? "")
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
        let unit = cmdInputView.units[at]
        guard let param = unit.param else {
            return
        }
        
        print("hello:\(unit.valueStr ?? "--")")
        let alert = UIAlertController(title: nil, message: "请输入默认值", preferredStyle: .alert)
        alert.addTextField { (textField) in
            if param.type == .int {
                textField.keyboardType = .numberPad
            }
        }
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            unit.param?.value = alert.textFields![0].text
            self.didFinishEditing()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func cancelEditReturnFormat() {
        switch returnFormat.type {
        case .bool:
            boolRadio.isSelected = true
        case .string:
            stringRadio.isSelected = true
        case .split:
            splitRadio.isSelected = true
        case .tlv:
            tlvRadio.isSelected = true
        }
        showExpressionAndPs(expression: returnFormat.expression, ps: returnFormat.ps)
    }
    
    
    func didFinishEditReturnFormat(format: ReturnFormat) {
        showExpressionAndPs(expression: format.expression, ps: format.ps)
    }
    
    func showExpressionAndPs(expression: String?, ps: String?) {
        expressionLbl.text = expression
        psLbl.text = ps
    }
}
