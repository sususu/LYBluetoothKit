//
//  TestConfigVC.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/27.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class TestConfigVC: BaseViewController,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
UICollectionViewDelegate {

    @IBOutlet weak var seg: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var product: DeviceProduct!
    var testUnits: [DeviceTestUnit] = []
    var itemSizes: [CGSize] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "自动测试配置"

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .vertical
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "TestConfigCell", bundle: nil), forCellWithReuseIdentifier: "cellId")
        
        for group in product.testGroups {
            for proto in group.protocols {
                let dt = DeviceTestUnit(name: proto.name, createTime: Date().timeIntervalSinceNow)
                dt.prol = proto
                testUnits.append(dt)
                
                let size = CGSize(width: dt.name.size(withFont: font(12)).width + 20, height: 30)
                itemSizes.append(size)
            }
        }
        
        setNavRightButton(text: "保存", sel: #selector(saveConfig))
        
    }

    
    // MARK: - 事件处理
    @objc func saveConfig() {
        
        var zcArr = [DeviceTestUnit]()
        for tu in testUnits {
            if tu.isZiCe {
                zcArr.append(tu)
            }
        }
        
        if seg.selectedSegmentIndex == 0 {
            product.pbxCsUnits = zcArr
        } else {
            product.ziceUnits = zcArr
        }
        ToolsService.shared.saveProduct(product)
        showSuccess("保存成功")
    }

    @IBAction func segValueChanged(_ sender: Any) {
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testUnits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TestConfigCell
        cell.update(withDeviceTestUnit: testUnits[indexPath.row])
//        cell.backgroundColor = kMainColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSizes[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        testUnits[indexPath.row].isZiCe = !testUnits[indexPath.row].isZiCe
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
