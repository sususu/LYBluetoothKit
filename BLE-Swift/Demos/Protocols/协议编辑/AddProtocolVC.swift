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
    
    @IBOutlet weak var hexRadio: DLRadioButton!
    
    @IBOutlet weak var customRadio: DLRadioButton!
    
    weak var delegate: AddProtocolVCDelegate?
    
    var previewLbl: YYLabel!
    @IBOutlet weak var psLbl: UILabel!
    
    var menu: ProtocolMenu!
    
    var proto: Protocol?
    
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
        boolRadio.otherButtons = [stringRadio, splitRadio, hexRadio, customRadio]

        self.title = TR("添加协议")
        if proto != nil {
            self.title = "编辑协议"
            reloadData()
        }
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }

    
    func reloadData() {
        nameTF.text = proto?.name
        returnFormat = proto?.returnFormat ?? boolReturnFormat()
        cmdInputView.units = proto?.cmdUnits ?? []
        
        if returnFormat.type == .bool {
            boolRadio.isSelected = true
        }
        else if returnFormat.type == .string {
            stringRadio.isSelected = true
        }
        else if returnFormat.type == .split {
            splitRadio.isSelected = true
        }
        else if returnFormat.type == .hex {
            hexRadio.isSelected = true
        }
        didFinishEditing()
    }

    // MARK: - 事件处理
    @objc func saveBtnClick() {
        self.view.endEditing(true)
        
        if cmdInputView.units.count == 0 {
            showError(TR("请输入指令"))
            return
        }
        
        guard let name = nameTF.text, name.count > 0 else {
            showError(TR("请输入名称"))
            return
        }
        
        var pl = Protocol()
        pl.name = name
        pl.cmdUnits = cmdInputView.units
        pl.returnFormat = returnFormat
        
        if proto != nil {
            proto?.name = name
            proto?.cmdUnits = cmdInputView.units
            proto?.returnFormat = returnFormat
            pl = proto!
        } else {
            menu.protocols.insert(pl, at: 0)
        }
        
        ProtocolService.shared.saveMenus()
        
        showSuccess(TR("Success"))
        
        delegate?.didAddNewProtocol(protocol: pl)
        
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
    
    @IBAction func hexBtnClick(_ sender: Any) {
        returnFormat = hexReturnFormat()
        cancelEditReturnFormat()
    }
    
    
    // MARK: - Delegate
    func didFinishEditing() {
        
        var string = ""
        
        var startIndexs = [Int]()
        
        for unit in cmdInputView.units {
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
        
        for i in 0 ..< cmdInputView.units.count {
            let unit = cmdInputView.units[i]
            
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
        
        previewLbl.attributedText = attrStr
    }
    
    
    func showDefaultValueInput(at: Int) {
        let unit = cmdInputView.units[at]
        guard let param = unit.param else {
            return
        }
        
        print("hello:\(unit.valueStr ?? "--")")
        
        if param.type == .int ||
            param.type == .date ||
            param.type == .time ||
            param.type == .datetime ||
            param.type == .enumeration {
            ParamsInputModalView.show(withStr: unit.valueStr!, okCallback: { (p) in
                unit.param = p
                self.didFinishEditing()
            }, cancelCallback: nil)
            ParamsInputModalView.setOldParam(param)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "请输入参数信息", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "参数名（选填）"
        }
        alert.addTextField { (textField) in
            if param.type == .int {
                textField.keyboardType = .numberPad
            }
            textField.placeholder = "默认值"
        }
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            unit.param?.label = alert.textFields![0].text
            unit.param?.value = alert.textFields![1].text
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
        case .hex:
            hexRadio.isSelected = true
        }
        showExpressionAndPs(expression: returnFormat.expression, ps: returnFormat.ps)
    }
    
    
    func didFinishEditReturnFormat(format: ReturnFormat) {
        self.returnFormat = format
        showExpressionAndPs(expression: format.expression, ps: format.ps)
    }
    
    func showExpressionAndPs(expression: String?, ps: String?) {
        expressionLbl.text = expression
        psLbl.text = ps
    }
}
