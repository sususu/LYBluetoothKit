//
//  OtaDataSection.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kPackageCountCallback = 20
let kSizeOfPieceData = 2048

struct OtaDataSection {
    
    var packageList = [Data]()
    var currentPackageIndex = 0
    var totalPackageCount = 0
    
    var sectionSize = 0
    var sectionData: Data
    
    
    init(data: Data) {
        
        sectionData = data
        sectionSize = data.count
        
        let sendSize = BLEConfig.shared.mtu
        let sendCount = sectionSize / sendSize
        
        let leftCount = sectionSize % sendSize
        
        totalPackageCount = leftCount > 0 ? sendCount + 1 : sendCount
        
        for i in 0..<sendCount {
            let package = data.subdata(in: i * sendSize..<(i + 1) * sendSize)
            packageList.append(package)
        }
        
        if leftCount > 0 {
            let package = data.subdata(in: (data.count - leftCount)..<(data.count))
            packageList.append(package)
        }
        
    }
    
}
