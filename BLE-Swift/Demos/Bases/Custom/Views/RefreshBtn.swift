//
//  RefreshBtn.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class RefreshBtn: UIButton {

    private var indicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    var isLoading: Bool {
        get {
            return !isEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        initViews()
    }
    
    func initViews() {
        indicator = UIActivityIndicatorView(style: .white)
        indicator.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        
        setImage(UIImage(), for: .disabled)
    }
    
    func startLoading() {
        isEnabled = false
        indicator.startAnimating()
    }
    
    func stopLoading() {
        isEnabled = true
        indicator.stopAnimating()
    }
    
}
