//
//  BaseTableViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/14.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseTableViewController: UITableViewController {

    var hideBack = false
    
    deinit {
        print("\(BaseTableViewController.self) dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        SVProgressHUD.setBackgroundColor(kMainColor)
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        if self.navigationController != nil && self.navigationController!.viewControllers.count > 1 &&
            !hideBack {
            setNavLeftButton(withIcon: "fanhui", sel: #selector(backBtnClick))
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
    
    func handleBleError(error: BLEError?) {
        DispatchQueue.main.async {
            guard let err = error else {
                self.showSuccess(TR("Cool"))
                return
            }
            self.showError(self.errorMsgFromBleError(err))
        }
    }
    
    
    var navigationBarHeight:CGFloat {
        return kiPhoneX_S ? 88 : 64
    }
    
    var bottomBarHeight:CGFloat {
        return kiPhoneX_S ? 34 : 0
    }
    
    // MARK: - 属性
    var width:CGFloat {
        return kScreenWidth
    }
    
    var height:CGFloat {
        return kScreenHeight - navigationBarHeight - bottomBarHeight
    }
    
    
    // MARK: - 导航条按钮
    func setNavLeftButton(text:String, sel:Selector?) {
        if self.navigationController == nil {
            return
        }

        let btn = UIButton(type: .custom)
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        
        
        let f = font(14)
        let textSize = text.size(withFont: f)
        btn.titleLabel?.font = f
        btn.frame = CGRect(x: 0, y: 0, width: textSize.width, height: 44)
        
        if sel != nil {
            btn.addTarget(self, action: sel!, for: .touchUpInside)
        }
        setNavLeftCustomView(view: btn)
    }
    
    func setNavRightButton(text:String, sel:Selector?) {
        if self.navigationController == nil {
            return
        }
        
        let btn = UIButton(type: .custom)
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        
        
        let f = font(14)
        let textSize = text.size(withFont: f)
        btn.titleLabel?.font = f
        btn.frame = CGRect(x: 0, y: 0, width: textSize.width, height: 44)
        
        if sel != nil {
            btn.addTarget(self, action: sel!, for: .touchUpInside)
        }
        setNavRightCustomView(view: btn)
    }
    
    func setNavLeftButton(withIcon iconStr:String, sel:Selector?) {
        if self.navigationController == nil {
            return
        }
        
        let btn = UIButton(type: .custom)
        let image = UIImage(named: iconStr)
        btn.setImage(image, for: .normal)
        
        var btnWidth:CGFloat = 44
        let btnHeight:CGFloat = 44
        
        if image != nil {
            btnWidth = image!.size.width / image!.size.height * btnHeight
            let offsetLeft = btnWidth - image!.size.width
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -offsetLeft, bottom: 0, right: 0)
        }

        btn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        
        if sel != nil {
            btn.addTarget(self, action: sel!, for: .touchUpInside)
        }
        setNavLeftCustomView(view: btn)
    }
    
    func setNavRightButton(withIcon iconStr:String, sel:Selector?) {
        if self.navigationController == nil {
            return
        }
        
        let btn = UIButton(type: .custom)
        let image = UIImage(named: iconStr)
        btn.setImage(image, for: .normal)
        
        var btnWidth:CGFloat = 44
        let btnHeight:CGFloat = 44
        
        if image != nil {
            btnWidth = image!.size.width / image!.size.height * btnHeight
            let offsetRight = btnWidth - image!.size.width
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -offsetRight)
        }
        
        btn.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        
        if sel != nil {
            btn.addTarget(self, action: sel!, for: .touchUpInside)
        }
        setNavRightCustomView(view: btn)
    }
    
    
    private func setNavLeftCustomView(view:UIView) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    private func setNavRightCustomView(view:UIView) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: view)
    }
    
    
    // MARK: - Loading
    let kTipDuration:TimeInterval = 3
    
    func dismissHUD(delay:TimeInterval) {
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
    func showTip(_ tip:String?) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showInfo(withStatus: tip)
        dismissHUD(delay: kTipDuration)
    }
    
    func showSuccess(_ tip:String?) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showSuccess(withStatus: tip)
        dismissHUD(delay: kTipDuration)
    }
    
    func showError(_ tip:String?) {
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.showError(withStatus: tip)
        dismissHUD(delay: kTipDuration)
    }
    
    func startLoading(_ tip:String?) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: tip)
    }
    
    func stopLoading() {
        SVProgressHUD.dismiss()
    }

    func alert(msg:String,
               confirmText:String = "OK",
               confirmSel:Selector? = nil,
               cancelText:String? = nil,
               cancelSel:Selector? = nil) {
        weak var weakSelf = self
        let alertCtrl = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmText, style: .default) { (action) in
            if confirmSel != nil {
                weakSelf?.performSelector(onMainThread: confirmSel!, with: nil, waitUntilDone: false)
            }
        }
        let cancelAction = UIAlertAction(title: cancelText ?? "", style: .cancel) { (action) in
            if cancelSel != nil {
                weakSelf?.performSelector(onMainThread: cancelSel!, with: nil, waitUntilDone: false)
            }
        }
        
        alertCtrl.addAction(confirmAction)
        if cancelText != nil {
            alertCtrl.addAction(cancelAction)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alertCtrl, animated: true, completion: nil)
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: true)
    }
}
