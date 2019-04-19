//
//  AddDeviceTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/16.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import YYKit
import DLRadioButton

class AddDeviceTestVC: BaseViewController, CmdInputViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ReturnFormatVCDelegate {

    
    var product: DeviceProduct!
    
    @IBOutlet weak var preContainerView: UIView!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var cmdInputView: CmdInputView!
    
    var previewLbl: YYLabel!

    @IBOutlet weak var boolRadio: DLRadioButton!
    
    @IBOutlet weak var stringRadio: DLRadioButton!
    
    @IBOutlet weak var splitRadio: DLRadioButton!
    
    @IBOutlet weak var hexRadio: DLRadioButton!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var expressionLbl: UILabel!
    
    @IBOutlet weak var psLbl: UILabel!
    var selectedGroupIndex: Int?
    
    var proto: Protocol?
    var oldGroup: DeviceTestGroup?
    
    var returnFormat = boolReturnFormat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TR("增加测试用例")
        
        let layout = TestGroupLayout()
        layout.itemSize = CGSize(width: 60, height: 28)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TestGroupCell", bundle: nil), forCellWithReuseIdentifier: "cellId")
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        previewLbl = YYLabel(frame: preContainerView.bounds)
        previewLbl.isUserInteractionEnabled = true
        previewLbl.numberOfLines = 0
        previewLbl.textVerticalAlignment = .top
        preContainerView.addSubview(previewLbl)
        
        cmdInputView.delegate = self
        
        boolRadio.isSelected = true
        boolRadio.otherButtons = [stringRadio, splitRadio, hexRadio]
        
        if proto != nil {
            title = TR("增加测试用例")
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
        
        if let g = oldGroup {
            for i in 0 ..< product.testGroups.count {
                if g.name == product.testGroups[i].name {
                    selectedGroupIndex = i
                    return
                }
            }
        }
        collectionView.reloadData()
        
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLbl.frame = preContainerView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
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
    
    // 事件处理
    @objc func saveBtnClick() {
        if cmdInputView.units.count == 0 {
            showError(TR("请输入指令"))
            return
        }
        
        guard let name = nameTF.text, name.count > 0 else {
            showError(TR("请输入名称"))
            return
        }
        
        guard let selectedIndex = selectedGroupIndex else {
            showError(TR("请选择分组"))
            return
        }
        
        let alert = UIAlertController(title: TR("保存测试单元"), message: TR("请确认\n分组：\(product.testGroups[selectedIndex].name)\n"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.saveTestUnit(name: name, units: self.cmdInputView.units, groupIndex: selectedIndex)
        }
        let cancel = UIAlertAction(title: TR("Cancel"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
        
        
    }
    func saveTestUnit(name: String, units: [CmdUnit], groupIndex: Int) {
        showSuccess(TR("Success"))
        
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
            let tg = product.testGroups[groupIndex]
            tg.protocols.insert(pl, at: 0)
        }
        
        ToolsService.shared.saveProduct(product)
        
        showSuccess(TR("Success"))
        
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
    }
    
    
    
    
    
    @IBAction func addGroupBtnClick(_ sender: Any?) {
        let alert = UIAlertController(title: nil, message: TR("Please input name"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.createTestGroup(withName: alert.textFields![0].text ?? "")
        }
        let cancel = UIAlertAction(title: TR("NO"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (tf) in
            tf.placeholder = "分组名"
//            tf.becomeFirstResponder()
        }
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func createTestGroup(withName name: String) {
        let name2 = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name2.count == 0 {
            showError("名字不能为空")
            addGroupBtnClick(nil);
            return
        }
        
        let group = DeviceTestGroup(name: name, createTime: Date().timeIntervalSince1970)
        product.testGroups.append(group)
        ToolsService.shared.saveProduct(product)
        collectionView.reloadData()
        showSuccess(TR("Success"))
    }
    
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.testGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TestGroupCell
        cell.updateUI(withGroup: product.testGroups[indexPath.row])
        if let selectedIndex = selectedGroupIndex, selectedIndex == indexPath.row {
            cell.updateSelected(selected: true)
        } else {
            cell.updateSelected(selected: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedGroupIndex == indexPath.row {
            // 提示删除
            let alert = UIAlertController(title: nil, message: "确定要删除吗？", preferredStyle: .alert)
            let ok = UIAlertAction(title: "删除", style: .default) { (action) in
                self.doDeleteGroupCellAtIndex(index: indexPath.row)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            navigationController?.present(alert, animated: true, completion: nil)
        } else {
            selectedGroupIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    
    func doDeleteGroupCellAtIndex(index: Int) {
        product.testGroups.remove(at: index)
        selectedGroupIndex = -1;
        ToolsService.shared.saveProduct(product)
        collectionView.reloadData()
        showSuccess(TR("Success"))
    }
    
    
    // MARK: - 代理
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
        showExpressionAndPs(expression: format.expression, ps: format.ps)
    }
        
    func showExpressionAndPs(expression: String?, ps: String?) {
        expressionLbl.text = expression
        psLbl.text = ps
    }
    
}
