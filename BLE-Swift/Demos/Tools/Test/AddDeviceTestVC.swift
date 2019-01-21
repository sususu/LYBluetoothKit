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
    
    @IBOutlet weak var tlvRadio: DLRadioButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var expressionLbl: UILabel!
    
    @IBOutlet weak var psLbl: UILabel!
    var selectedGroupIndex: Int?
    
    var returnFormat = boolReturnFormat()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TR("增加测试用例")
        
        let layout = TestGroupLayout()
        layout.itemSize = CGSize(width: 80, height: 30)
        layout.minimumLineSpacing = 8
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
        boolRadio.otherButtons = [stringRadio, splitRadio, tlvRadio]
        stringRadio.otherButtons = [boolRadio, splitRadio, tlvRadio]
        splitRadio.otherButtons = [boolRadio, stringRadio, tlvRadio]
        tlvRadio.otherButtons = [boolRadio, stringRadio, splitRadio]
        
        
        setNavRightButton(text: TR("SAVE"), sel: #selector(saveBtnClick))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLbl.frame = preContainerView.bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    

    // MARK: - Delegate
    func didFinishEditing() {
        
        var string = ""
        let rangesArr = NSMutableArray()
        let nrArr = NSMutableArray()
        
        for unit in cmdInputView.units {
            let range = NSRange(location: string.count, length: (unit.valueStr ?? "").count)
            if unit.type == .variable {
                rangesArr.append(NSValue(range: range))
            } else {
                nrArr.append(NSValue(range: range))
            }
            string = string + (unit.valueStr ?? "") + "  "
        }
        
        let attrStr = NSMutableAttributedString(string: string)
        attrStr.lineSpacing = 5
        attrStr.font = font(14)
        attrStr.color = kMainColor
        
        let markColor = UIColor.red
        for val in rangesArr {
            let range = (val as! NSValue).rangeValue
            attrStr.setUnderlineStyle(.single, range: range)
            
            attrStr.setTextHighlight(range, color: markColor, backgroundColor: UIColor.clear) { (containerView, attrStr, range, rect) in
                print("hello,click")
            }
        }
        for val in nrArr {
            let range = (val as! NSValue).rangeValue
            attrStr.setUnderlineStyle(.single, range: range)
            attrStr.setUnderlineColor(rgb(200, 200, 200), range: range)
        }
//        attrStr.setKern(NSNumber(value: 5), range: NSRange(location: 0, length: string.count))
        previewLbl.attributedText = attrStr
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
        
        let alert = UIAlertController(title: TR("保存测试单元"), message: TR("请确认\n分组：\(product.testGroups![selectedIndex])\n"), preferredStyle: .alert)
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
    
    
    @IBAction func addGroupBtnClick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: TR("Please input name"), preferredStyle: .alert)
        let ok = UIAlertAction(title: TR("OK"), style: .default) { (action) in
            self.createTestGroup(withName: alert.textFields![0].text ?? "")
        }
        let cancel = UIAlertAction(title: TR("NO"), style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (tf) in
            tf.placeholder = TR("Group name")
            tf.becomeFirstResponder()
        }
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func createTestGroup(withName name: String) {
        let group = DeviceTestGroup(name: name, createTime: Date().timeIntervalSince1970)
        if product.testGroups == nil {
            product.testGroups = [DeviceTestGroup]()
        }
        product.testGroups!.append(group)
        ToolsService.shared.saveProduct(product)
        collectionView.reloadData()
        showSuccess(TR("Success"))
    }
    
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.testGroups?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TestGroupCell
        cell.updateUI(withGroup: product.testGroups![indexPath.row])
        if let selectedIndex = selectedGroupIndex, selectedIndex == indexPath.row {
            cell.updateSelected(selected: true)
        } else {
            cell.updateSelected(selected: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGroupIndex = indexPath.row
        collectionView.reloadData()
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
