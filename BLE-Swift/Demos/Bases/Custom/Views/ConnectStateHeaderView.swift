//
//  ConnectStateHeaderView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class ConnectStateHeaderView: UIView {

    var stateBtn: UIButton!
    
    var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        initViews()
    }
    
    
    func initViews() {
        stateBtn = UIButton(type: .custom)
        stateBtn.frame = self.bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5))
        stateBtn.backgroundColor = kMainColor
        stateBtn.layer.cornerRadius = 5
//        stateBtn.layer.masksToBounds = true
        stateBtn.addTarget(self, action: #selector(stateBtnClick), for: .touchUpInside)
        stateBtn.titleLabel?.font = font(12)
//        stateBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
//        stateBtn.layer.shadowColor = rgb(80, 80, 80).cgColor
//        stateBtn.layer.shadowOpacity = 0.6
        
        addSubview(stateBtn)
        
        stateChangeUI()
        
        addObserver()
        
        timer = Timer(timeInterval: 2, target: self, selector: #selector(updateDeviceRssi), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidConnect), name: BLENotification.deviceConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDidDisconnect), name: BLENotification.deviceDisconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bleStateChanged), name: BLENotification.stateChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rssiUpdateNotification(notification:)), name: BLENotification.deviceRssiUpdate, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        stateChangeUI()
    }
    
    @objc func deviceDidConnect() {
        stateChangeUI()
    }
    
    @objc func deviceDidDisconnect() {
        stateChangeUI()
    }
    
    @objc func bleStateChanged() {
        stateChangeUI()
    }
    
    func stateChangeUI() {
        let center = BLECenter.shared
        if center.state != .poweredOn {
            stateBtn.setTitle(TR("BLE Unavailable"), for: .normal)
        } else {
            if let name = center.defaultInteractionDeviceName {
                let device = center.connectedDevices[0]
                let title = name + "   信号：\(device.rssi!)"
                stateBtn.setTitle(title, for: .normal)
            } else {
                stateBtn.setTitle(TR("Disconnected"), for: .normal)
            }
        }
    }
    
    // MARK: - 事件处理
    @objc func stateBtnClick() {
        NotificationCenter.default.post(name: kShowConnectNotification, object: nil)
    }
    
    
    @objc func rssiUpdateNotification(notification: Notification) {
        guard let _ = notification.userInfo else {
            return
        }
        
//        let device = userInfo[BLEKey.device] as! BLEDevice
        stateChangeUI()
    }

    @objc func updateDeviceRssi() {
        for d in BLECenter.shared.connectedDevices {
            d.updateRssi()
        }
    }
    
}
