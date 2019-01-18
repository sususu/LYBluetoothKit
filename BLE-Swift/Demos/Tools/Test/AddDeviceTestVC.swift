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

class AddDeviceTestVC: BaseViewController, CmdInputViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TR("增加测试用例")
        
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
        
    }
    
    @IBAction func splitBtnClick(_ sender: Any) {
    }
    
    @IBAction func tlvBtnClick(_ sender: Any) {
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
    }
    
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.testGroups?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TestGroupCell
        cell.updateUI(withGroup: product.testGroups![indexPath.row])
        return cell
    }
}
