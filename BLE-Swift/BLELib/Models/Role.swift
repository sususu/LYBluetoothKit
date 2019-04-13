//
//  Role.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/4/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

enum RoleType: Int {
    case developer
    case tester
}

class AppConfig {
    public static let current = AppConfig()
    
    var roleType: RoleType = .developer
    var mtuForApollo3: Int = 128
    var mtu: Int = 20
    
    init() {
        
        roleType = RoleType(rawValue:UserDefaults.standard.integer(forKey: "roleType")) ?? RoleType.developer
        
        mtuForApollo3 = UserDefaults.standard.integer(forKey: "mtuForApollo3")
        mtu = UserDefaults.standard.integer(forKey: "mtu")
        if mtu < 20 {
            mtu = 20
//            save()
        }
        
        if mtuForApollo3 == 0 {
            mtuForApollo3 = 128
//            save()
        }
    }
    
    func save() {
        UserDefaults.standard.set(roleType.rawValue, forKey: "roleType")
        
        UserDefaults.standard.set(mtuForApollo3, forKey: "mtuForApollo3")
        UserDefaults.standard.set(mtu, forKey: "mtu")
        
        UserDefaults.standard.synchronize()
    }
}
