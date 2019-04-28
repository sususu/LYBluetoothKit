//
//  LYNavigationController.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/2.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class LYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        
        let navbar = self.navigationBar
        navbar.barTintColor = UIColor.white
        navbar.setBackgroundImage(image(withColor: UIColor.white), for: .default)
    }

    func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let cxt = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        cxt.setFillColor(color.cgColor)
        cxt.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }

}
