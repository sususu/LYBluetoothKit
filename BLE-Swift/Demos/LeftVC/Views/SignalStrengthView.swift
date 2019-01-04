//
//  SignalStrengthView.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/3.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

let kSignalStrengthBgColor = rgb(180, 180, 180)
let kSignalStrengthBadColor = rgb(200, 30, 30)
let kSignalStrengthGoodColor = rgb(30, 200, 30)

class SignalStrengthView: UIView {

    /// 信号强度 -100 ~ 0
    var strength: Int  = -100 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var txtLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        initViews()
    }
    
    func initViews() {
        txtLbl = UILabel(frame: CGRect(x: 0, y: frame.height - 15, width: frame.width, height: 15))
        txtLbl.font = font(10)
        txtLbl.textAlignment = .center
        addSubview(txtLbl)
    }
    
    override func draw(_ rect: CGRect) {
        let span = bounds.width / 9
        let width = span
        let unitHeight = (bounds.height - txtLbl.bounds.height) / 5
        
        // 两个代码除了颜色不一样，其他一样
        drawBg(width: width, span: span, unitHeight: unitHeight)
        drawStrenth(width: width, span: span, unitHeight: unitHeight)
    }
    
    func drawBg(width: CGFloat, span: CGFloat, unitHeight: CGFloat) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        ctx?.setLineWidth(width)
        ctx?.setLineJoin(.round)
        ctx?.setLineCap(.round)
        ctx?.setStrokeColor(kSignalStrengthBgColor.cgColor)
        
        let path = UIBezierPath()
        for i in 0..<5 {
            let height = CGFloat((i + 1)) * unitHeight
            let x = width / 2 + CGFloat(i) * (width + span)
            let y = self.bounds.height - txtLbl.bounds.height
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: y - height))
        }
        ctx?.addPath(path.cgPath)
        ctx?.strokePath()
        ctx?.restoreGState()
    }

    func drawStrenth(width: CGFloat, span: CGFloat, unitHeight: CGFloat) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        ctx?.setLineWidth(width)
        ctx?.setLineJoin(.round)
        ctx?.setLineCap(.round)
        
        if strength >= -60 {
            ctx?.setStrokeColor(kSignalStrengthGoodColor.cgColor)
            txtLbl.textColor = kSignalStrengthGoodColor
        } else {
            ctx?.setStrokeColor(kSignalStrengthBadColor.cgColor)
            txtLbl.textColor = kSignalStrengthBadColor
        }
        
        
        var toIndex = 0;
        switch strength {
        case -99 ..< -85:
            toIndex = 1
        case -85 ..< -75:
            toIndex = 2
        case -75 ..< -60:
            toIndex = 3
        case -60 ..< -25:
            toIndex = 4
        case -25 ..< 1:
            toIndex = 5
        default:
            toIndex = 0
        }
        
        if strength <= -100 {
            txtLbl.text = "--"
            txtLbl.textColor = kSignalStrengthBgColor
        } else {
            txtLbl.text = "\(strength)"
        }
        
        
        
        let path = UIBezierPath()
        for i in 0..<toIndex {
            let height = CGFloat((i + 1)) * unitHeight
            let x = width / 2 + CGFloat(i) * (width + span)
            let y = self.bounds.height - txtLbl.bounds.height
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x, y: y - height))
        }
        ctx?.addPath(path.cgPath)
        ctx?.strokePath()
        ctx?.restoreGState()
    }
}
