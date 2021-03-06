//
//  AddDeviceCircleTestVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol AddDeviceCircleTestVCDelegate: NSObjectProtocol {
    func didAddDeviceCT(ct: CircleTest, forGroup:CircleGroup)
}

class AddDeviceCircleTestVC: BaseViewController, CmdKeyBoardViewDelegate {
    
    var delegate: AddDeviceCircleTestVCDelegate?
    
    var group: CircleGroup!
    
    
    @IBOutlet weak var cmdTF: UITextField!
    private var keyboard = CmdKeyBoardView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "测试操作"
        
        keyboard.delegate = self
        cmdTF.inputView = keyboard
        
        setNavRightButton(text: "完成", sel: #selector(finishAdd))
    }
    
    // MARK: - 事件处理
    @objc func finishAdd() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func connectTestClick(_ sender: Any) {
        showInputTimeInterval(withType: 0)
    }
    
    @IBAction func disconnectTestClick(_ sender: Any) {
        showInputTimeInterval(withType: 1)
    }
    
    @IBAction func cmdTestClick(_ sender: Any) {
        guard let cmdStr = cmdTF.text, cmdStr.count > 0 else {
            showError("请先输入指令")
            return
        }
        showInputTimeInterval(withType: 2)
    }
    
    
    func showInputTimeInterval(withType type: Int) {
        let alert = UIAlertController(title: nil, message: "请输入时间间隔（与上一个操作的时间间隔）", preferredStyle: .alert)
        if type >= 2 {
            alert.addTextField { (tf) in
                tf.placeholder = "指令名称"
            }
        }
        alert.addTextField { (tf) in
            tf.placeholder = "间隔（秒）"
            tf.keyboardType = .numberPad
        }
        weak var weakSelf = self
        let ok = UIAlertAction(title: "确定", style: .default) { (action) in
            var name = ""
            var spanStr = "0"
            if type == 0 {
                name = "链接设备"
                spanStr = alert.textFields![0].text ?? "0"
            }
            else if type == 1 {
                name = "断开链接"
                spanStr = alert.textFields![0].text ?? "0"
            }
            else {
                name = alert.textFields![0].text ?? "指令执行"
                spanStr = alert.textFields![1].text ?? "0"
                name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                spanStr = spanStr.trimmingCharacters(in: .whitespacesAndNewlines)
                if name.count == 0 {
                    name = "指令执行"
                }
                if spanStr.count == 0 {
                    spanStr = "0"
                }
            }
            
            let ct = CircleTest()
            ct.name = name
            ct.type = CircleTestType(rawValue: type)!
            ct.span = TimeInterval(spanStr) ?? 0
            weakSelf?.delegate?.didAddDeviceCT(ct: ct, forGroup: weakSelf!.group)
            weakSelf?.showSuccess("添加成功")
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func didEnterStr(str: String) {
        if str.hasPrefix("Str") ||
            str.hasPrefix("Int") ||
            str.hasPrefix("Len") {
            return
        }
        cmdTF.text = (cmdTF.text ?? "") + str
    }
    
    func didFinishInput() {
        
    }
    func didFallback() {
        
        guard let text = cmdTF.text, text.count > 0 else {
            return
        }
        
        cmdTF.text = String(text.prefix(text.count - 1))
    }
}
