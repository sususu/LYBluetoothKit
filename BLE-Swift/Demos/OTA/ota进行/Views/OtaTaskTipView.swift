//
//  OtaTaskTipView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

protocol OtaTaskTipViewDelegate: NSObjectProtocol {
    func didClickShowDetailBtn()
}


class OtaTaskTipView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    var showDetailBtn: UIButton!
    var placeLbl: UILabel!
    
    var delegate: OtaTaskTipViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaTaskAddNotification(notification:)), name: kOtaManagerAddTaskNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaTaskRemoveNotification(notification:)), name: kOtaManagerRemoveTaskNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(otaTasksRemoveAllNotification(notification:)), name: kOtaManagerRemoveAllTasksNotification, object: nil)
        
        let height = self.bounds.height - 0.1
        let width = height * 2
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.allowsSelection = false
        collectionView.register(UINib(nibName: "TaskSummaryCell", bundle: nil), forCellWithReuseIdentifier: "cellId")
        collectionView.backgroundColor = UIColor.clear
        
        addSubview(collectionView)
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = rgb(200, 30, 30)
        btn.setTitle(TR("Detail"), for: .normal)
        btn.titleLabel?.font = font(14)
        btn.addTarget(self, action: #selector(showDetailBtnClick), for: .touchUpInside)
        addSubview(btn)
        showDetailBtn = btn
        
        placeLbl = UILabel(frame: self.bounds)
        placeLbl.textColor = rgb(200, 200, 200)
        placeLbl.text = TR("No Task")
        placeLbl.font = font(16)
        placeLbl.textAlignment = .center
//        placeLbl.isUserInteractionEnabled = true
        addSubview(placeLbl)
        
        
        updateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeLbl.frame = self.bounds
        
        let btnWidth:CGFloat = 40
        
        showDetailBtn.frame = CGRect(x: self.bounds.width - 45, y: (self.bounds.height - btnWidth) / 2, width: btnWidth, height: btnWidth)
        showDetailBtn.layer.cornerRadius = showDetailBtn.bounds.height / 2
        
        collectionView.frame = CGRect(x: 0, y: 0, width: self.bounds.width - 50, height: self.bounds.height)
    }
    
    
    func updateUI() {
        showDetailBtn.isHidden = true
        if OtaManager.shared.taskList.count == 0 {
            placeLbl.isHidden = false
//            showDetailBtn.isHidden = true
        } else {
            placeLbl.isHidden = true
//            showDetailBtn.isHidden = false
        }
        showDetailBtn.setTitle("\(OtaManager.shared.taskList.count)", for: .normal)
        collectionView.reloadData()
    }
    
    @objc func otaTaskAddNotification(notification: Notification) {
        updateUI()
    }
    
    @objc func otaTaskRemoveNotification(notification: Notification) {
        updateUI()
    }
    
    @objc func otaTasksRemoveAllNotification(notification: Notification) {
        updateUI()
    }
    
    @objc func showDetailBtnClick() {
        delegate?.didClickShowDetailBtn()
    }
    
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OtaManager.shared.taskList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TaskSummaryCell
        cell.updateCell(withTask: OtaManager.shared.taskList[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didClickShowDetailBtn()
    }
}

