//
//  HomeViewController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let otaVC = OtaViewController()
        let protocolVC = ProtocolViewController()
        let toolsVC = ToolsViewController()
        let settingsVC = SettingsViewController()
        
        register(vc: otaVC, title: TR("OTA"), iconName: "icon_protocol", selectedIconName: "icon_protocol_sel")
        
        register(vc: protocolVC, title: TR("Procotol"), iconName: "ota_icons_off", selectedIconName: "ota_icons_on")
        
        register(vc: toolsVC, title: TR("Tools"), iconName: "tool_icons_off", selectedIconName: "tool_icons_on")
        
        register(vc: settingsVC, title: TR("Settings"), iconName: "setting_icons_off", selectedIconName: "setting_icons_on")
        
        self.tabBar.tintColor = kMainColor
    }
    

    
    func register(vc: UIViewController, title: String?, iconName: String, selectedIconName: String) {
        vc.title = title
        let nav = LYNavigationController(rootViewController: vc)
        let tabbarItem = UITabBarItem(title: title, image: UIImage(named: iconName), selectedImage: UIImage(named: selectedIconName))
        nav.tabBarItem = tabbarItem
        addChild(nav)
    }
    

}
