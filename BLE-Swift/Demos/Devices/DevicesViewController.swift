//
//  DevicesViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/16.
//  Copyright © 2018 ss. All rights reserved.
//

import UIKit

class DevicesViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TR("Connected Devices")

        let layout = UICollectionViewFlowLayout()
        let space:CGFloat = 10
        layout.itemSize = CGSize(width: self.width / 2 - space * 3, height: self.width / 2 * 1.2)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.view.bounds.height), collectionViewLayout: layout)
        collectionView.register(DevicesCell.self, forCellWithReuseIdentifier: kDevicesCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = rgb(230, 230, 230)
        self.view.addSubview(collectionView)
        
        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BLECenter.shared.connectedDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDevicesCellId, for: indexPath) as! DevicesCell
        cell.device = BLECenter.shared.connectedDevices[indexPath.item];
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = BLECenter.shared.connectedDevices[indexPath.item];
//        BLECenter.shared.defaultInteractionDeviceName = device.name
        let vc = DeviceInfoViewController(device: device);
//        let vc = DevicesVC()
        navigationController?.pushViewController(vc, animated: true)
    }

}
