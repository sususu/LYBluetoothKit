//
//  SportVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class SportVC: BaseViewController {

    @IBOutlet weak var summaryLbl: UILabel!
    
    @IBOutlet weak var numLbl: UILabel!
    
    var num: Int = 0
    var sports: Array<Sport>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showConnectState()
        // Do any additional setup after loading the view.
    }

    @IBAction func numBtnClick(_ sender: Any) {
        
        self.summaryLbl.text = ""
        self.sports = nil
        
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getSportSleepDataNum(callback: { (sportNum, sleepNum, err) in
            weakSelf?.stopLoading()
            
            if let error = err {
                weakSelf?.handleBleError(error: error)
                return
            }
            
            weakSelf?.num = sportNum
            
            weakSelf?.numLbl.text = "\(sportNum)个"
        })
    }
    
    @IBAction func detailBtnClick(_ sender: Any) {
        if num == 0 {
            self.showError("个数为0，不能获取详情")
            return
        }
        
        
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.getSportDetail(num: self.num, callback: { (sports, err) in
            weakSelf?.stopLoading()
            if let error = err {
                weakSelf?.handleBleError(error: error)
                return
            }
            
            guard let sportArr = sports, sportArr.count > 0 else {
                weakSelf?.showError("返回数据为空")
                return
            }
            
            weakSelf?.sports = sportArr
            var steps = 0
            var du = 0
            var cal = 0
            var dis = 0
            
            for s in sportArr {
                steps += s.step
                du += s.duration
                cal += s.calorie
                dis += s.distance
            }
            
            let str = "数量:\(weakSelf?.num ?? 0)\nstep:\(steps)\ncalorie:\(cal)\ndistance:\(dis)\nduration:\(du)"
            weakSelf?.summaryLbl.text = str
        })
    }
    
    @IBAction func seeDetailBtnClick(_ sender: Any) {
        guard let sports = self.sports, sports.count > 0 else {
            showError("运动数据为空")
            return
        }
        let vc = SportDetailVC()
        vc.sports = sports
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func delBtnClick(_ sender: Any) {
        startLoading(nil)
        weak var weakSelf = self
        _ = BLECenter.shared.deleteSportDatas(callback: { (bool, err) in
            if let error = err {
                weakSelf?.handleBleError(error: error)
                return
            }
            weakSelf?.showSuccess("删除成功")
        })
    }
    
    
}
