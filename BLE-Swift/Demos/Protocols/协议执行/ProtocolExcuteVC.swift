//
//  ProtocolExcuteVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/26.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import YYKit

class ProtocolExcuteVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AddProtocolVCDelegate {

    var proto: Protocol!
    var protocols: [Protocol]!
    var selectedIndex: Int = 0
    var itemSizes: [CGSize] = []
    
    var runner = ProtocolRunner()
    
    @IBOutlet weak var cmdTV: UITextView!
    
    var previewLbl: YYLabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var logTV: UITextView!
    
    @IBOutlet weak var countTF: UITextField!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var excuteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for proto in protocols {
            let size = CGSize(width: proto.name.size(withFont: font(12)).width + 20, height: 30)
            itemSizes.append(size)
        }
        
        showConnectState()
        
//        cmdTV.isUserInteractionEnabled = false
        previewLbl = YYLabel(frame: cmdTV.bounds)
        previewLbl.isUserInteractionEnabled = true
        previewLbl.numberOfLines = 0
        previewLbl.textVerticalAlignment = .top
        cmdTV.addSubview(previewLbl)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.scrollDirection = .vertical
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "OtherProtocolCell", bundle: nil), forCellWithReuseIdentifier: "cellId")
        
        setNavRightButton(text: "编辑", sel: #selector(editBtnClick))
        
        reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLbl.frame = cmdTV.bounds
    }
    
    func reloadData() {
        
        proto = protocols[selectedIndex]
        
        self.titleLbl.text = proto.name
        
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
        
        if param.type == .enumeration {
            EnumSelectModalView.show { (enm) in
                param.value = enm.0 + ":\(enm.1)"
                self.reloadData()
            }
            EnumSelectModalView.setOldParam(param)
            return
        }
        
        else if param.type == .int {
            NumberInputModalView.show { (intValue) in
                param.value = "\(intValue)"
                self.reloadData()
            }
            NumberInputModalView.setOldParam(param)
            return
        }
        
        else if param.type == .time || param.type == .date || param.type == .datetime {
            self.alert(msg: "会自动填充系统的日期时间", confirmText: "好的", confirmSel: nil, cancelText: nil, cancelSel: nil)
            return
        }
        
        
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
        let vc = AddProtocolVC()
        vc.proto = proto
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private var isRunning: Bool = false
    @IBAction func excuteBtnClick(_ sender: Any) {
        
        if isRunning {
            printLog("正在执行，请耐心等待")
        }
        
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
            let str = weakSelf?.getJSONStringFromDictionary(dictionary: dict)
            weakSelf?.resultStr = str
            weakSelf?.excuteFinish(resultStr: "返回：\(str ?? "")")
        }, dictArrayCallback: { (dictArr) in
            let result = weakSelf?.getJSONStringFromArray(array: dictArr)
            weakSelf?.resultStr = result
            weakSelf?.excuteFinish(resultStr: "返回：\(result ?? "")")
        }) { (error) in
            weakSelf?.excuteFinish(resultStr: "错误：" + (weakSelf?.errorMsgFromBleError(error) ?? ""))
        }
        
    }
    
    func getJSONStringFromDictionary(dictionary:Dictionary<String, Any>) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data = try? JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        
        return String(bytes: data ?? Data(), encoding: .utf8) ?? "";
    }
    
    //数组转json
    func getJSONStringFromArray(array:Array<Dictionary<String, Any>>) -> String {
        
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("无法解析出JSONString")
            return ""
        }
        
        let data = try? JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        let JSONString = String(bytes:data ?? Data(), encoding: .utf8) ?? ""
        return JSONString
        
    }
    
    
    func excuteFinish(resultStr: String?) {
        excuteBtn.isEnabled = true
        self.isRunning = false
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
    
    
    
    
    // MARK: - collectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return protocols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! OtherProtocolCell
        cell.update(withProtocol: protocols[indexPath.row], selected: (indexPath.row == selectedIndex))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSizes[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        reloadData()
    }
    
    func didAddNewProtocol(protocol: Protocol) {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        reloadData()
    }
}
