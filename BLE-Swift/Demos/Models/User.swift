//
//  User.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kCurrentUserIDKey = "kCurrentUserIDKey"
let kCurrentUserNameKey = "kCurrentUserNameKey"
let kCurrentUserEmailKey = "kCurrentUserEmailKey"
let kCurrentUserJwtKey = "kCurrentUserJwtKey"

class User: Codable {
    
    static let current = User()
    
    private init() {
        self.id = StorageUtils.getString(forKey: kCurrentUserIDKey) ?? ""
        self.name = StorageUtils.getString(forKey: kCurrentUserNameKey) ?? ""
        self.email = StorageUtils.getString(forKey: kCurrentUserEmailKey) ?? ""
        self.jwt = StorageUtils.getString(forKey: kCurrentUserJwtKey) ?? ""
    }
    
    func save() {
        StorageUtils.saveString(self.id, forKey: kCurrentUserIDKey)
        StorageUtils.saveString(self.name, forKey: kCurrentUserNameKey)
        StorageUtils.saveString(self.email, forKey: kCurrentUserEmailKey)
        StorageUtils.saveString(self.jwt, forKey: kCurrentUserJwtKey)
    }
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var isadmin: Bool = false
    
    var jwt: String = ""
    
    var isLogin: Bool {
        get {
            return id.count > 0
        }
    }
    
    func logout() {
        id = ""
        name = ""
        email = ""
        isadmin = false
        jwt = ""
        save()
    }
}
