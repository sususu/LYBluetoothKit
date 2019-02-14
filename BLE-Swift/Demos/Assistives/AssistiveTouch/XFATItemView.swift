//
//  XFATItemView.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/1/5.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
enum XFATItemViewType : Int {
    case none = 0
    case system = 1
    case back = 2
    case star = 3
    case count = 10
}

enum XFATInnerCircle : Int {
    case small
    case middle
    case large
}


class XFATItemView: UIView {
    required init(layer: CALayer?) {
        super.init(frame: CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemWidth(), height: XFATLayoutAttributes.itemWidth()))
        
        if layer != nil {
            layer?.contentsScale = UIScreen.main.scale
            if (layer?.bounds.equalTo(CGRect.zero))! {
                layer?.bounds = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
            }
            if (layer?.position.equalTo(CGPoint.zero))! {
                layer?.position = CGPoint(x: XFATLayoutAttributes.itemWidth() / 2, y: XFATLayoutAttributes.itemWidth() / 2)
            }
            if let layer = layer {
                self.layer.addSublayer(layer)
            }
        }
        
    }
    
    class func item(with type: XFATItemViewType) -> Self {
        var layer: CALayer? = nil
        switch type {
        case .system:
            layer = self.createLayerSystemType()
        case .none:
            layer = self.createLayerWithNoneType()
        case .back:
            layer = self.createLayerBackType()
        case .star:
            layer = self.createLayerStarType()
        default:
            if type.rawValue >= XFATItemViewType.count.rawValue {
                let count: Int = type.rawValue - XFATItemViewType.count.rawValue
                layer = self.createLayer(withCount: count)
            }
        }
        let item = self.init(layer: layer)
        if type == .system {
            item.bounds = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
            item.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        }
        return item
    }
    
    class func item(with layer: CALayer?) -> Self {
        return self.init(layer: layer)
    }
    
    class func item(with image: UIImage?) -> Self {
        let size = CGSize(width: min((image?.size.width)!, XFATLayoutAttributes.itemWidth()), height: min((image?.size.height)!, XFATLayoutAttributes.itemWidth()))
        let layer = CALayer()
        layer.contents = image?.cgImage
        layer.bounds = CGRect(x: 0, y: 0, width: min(size.width, XFATLayoutAttributes.itemImageWidth()), height: min(size.height, XFATLayoutAttributes.itemImageWidth()))
        return self.init(layer: layer)
    }
    
    var position: XFATPosition?
    
    override convenience init(frame: CGRect) {
        self.init(layer: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(layer: nil)
    }
    
    // MARK: - CreateLayer
    class func createLayerWithNoneType() -> CALayer? {
        return CALayer()
    }
    
    class func createLayerSystemType() -> CALayer? {
        let layer = CALayer()
        if let create = self.createInnerCircle(.large) {
            layer.addSublayer(create)
        }
        if let create = self.createInnerCircle(.middle) {
            layer.addSublayer(create)
        }
        if let create = self.createInnerCircle(.small) {
            layer.addSublayer(create)
        }
        layer.position = CGPoint(x: XFATLayoutAttributes.itemImageWidth() / 2, y: XFATLayoutAttributes.itemImageWidth() / 2)
        return layer
    }
    
    class func createLayerBackType() -> CALayer? {
        let layer = CAShapeLayer()
        let size = CGSize(width: 22, height: 22)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: 8.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: 3.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width, y: 3.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width, y: -3.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: -3.5 + size.height / 2))
        path.addLine(to: CGPoint(x: size.width / 2, y: -8.5 + size.height / 2))
        path.close()
        layer.path = path.cgPath
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
    
    class func createLayerStarType() -> CALayer? {
        let layer = CAShapeLayer()
        let size = CGSize(width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
        let numberOfPoints: Double = 5
        let starRatio: Double = 0.5
        let steps: Double = numberOfPoints * 2
        let outerRadius: Double = Double(min(size.height, size.width) / 2)
        let innerRadius: Double = outerRadius * starRatio
        let stepAngle: Double = 2 * .pi / steps
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let path = UIBezierPath()
        for i in 0..<Int(steps) {
            let radius: Double = i % 2 == 0 ? outerRadius : innerRadius
            let angle: Double = Double(i) * stepAngle - Double.pi / 2
            let x: Double = radius * cos(angle) + Double(center.x)
            let y: Double = radius * sin(angle) + Double(center.y)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }
    
    class func createLayer(withCount count: Int) -> CALayer? {
        let layer = CAShapeLayer()
        let bounds = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
        let path = UIBezierPath(ovalIn: bounds)
        path.append(UIBezierPath(ovalIn: bounds.insetBy(dx: 5, dy: 5)).reversing())
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.bounds = bounds
        
        let textLayer = CATextLayer()
        if count >= 10 || count < 0 {
            textLayer.string = "!"
        } else {
            textLayer.string = String(format: "%ld", count)
        }
        textLayer.fontSize = 48
        textLayer.alignmentMode = .center
        textLayer.bounds = bounds
        textLayer.position = CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
        textLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(textLayer)
        
        return layer
    }
    
    class func createInnerCircle(_ circleType: XFATInnerCircle) -> CAShapeLayer? {
        
        // iPad   width 390 itemWidth 76 margin 2 corner:14  48-41-33
        // iPhone width 295 itemWidth 60 margin 2 corner:14  44-38-30
        
        var circleAlpha: CGFloat = 0
        var radius: CGFloat = 0
        var borderAlpha: CGFloat = 0
        switch circleType {
        case .small:
            circleAlpha = 1
            radius = IS_IPAD_IDIOM ? 16 : 14.5
            borderAlpha = 0.3
        case .middle:
            circleAlpha = 0.4
            radius = IS_IPAD_IDIOM ? 20 : 18.5
            borderAlpha = 0.15
        case .large:
            circleAlpha = 0.2
            radius = IS_IPAD_IDIOM ? 24 : 22
            borderAlpha = 0
        default:
            break
        }
        let layer = CAShapeLayer()
        let position = CGPoint(x: XFATLayoutAttributes.itemImageWidth() / 2, y: XFATLayoutAttributes.itemImageWidth() / 2)
        let path = UIBezierPath(arcCenter: position, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.fillColor = UIColor(white: 1, alpha: circleAlpha).cgColor
        layer.strokeColor = UIColor(white: 0, alpha: borderAlpha).cgColor
        layer.bounds = CGRect(x: 0, y: 0, width: XFATLayoutAttributes.itemImageWidth(), height: XFATLayoutAttributes.itemImageWidth())
        layer.position = CGPoint(x: position.x, y: position.y)
        layer.contentsScale = UIScreen.main.scale
        return layer
    }
}
