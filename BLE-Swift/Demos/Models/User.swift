//
//  User.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class User: Codable {
    var id: String = ""
    var name: String!
    var email: String!
    
    var jwt: String!
    
    var isLogin: Bool {
        get {
            return id.count > 0
        }
    }
    
    
}
