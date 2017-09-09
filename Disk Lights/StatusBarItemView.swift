//
//  StatusBarItemView.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/23/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa
import Foundation

class StatusBarItemView: NSView, CAAnimationDelegate {
    
    let topLayer  = CAShapeLayer()
    let bottomLayer  = CAShapeLayer()
    
    let scaleStart = CGFloat(1.0)
    let scaleEnd = CGFloat(3.0)
    let shapeRadius = CGFloat(2)
    
    let itemWidth = CGFloat(8)
    let itemHeight = CGFloat(8)
    let itemPadding = CGFloat(20)
    
    override func awakeFromNib() {
        Swift.print("AWAKE FROM NIB")
        
    }
    init() {
        super.init(frame: NSRect(x:0,
                                 y:0,
                                 width:itemWidth + itemPadding,
                                 height:2*(itemHeight+itemPadding))
        )
        
        wantsLayer = true
        
        // Top and bottom frames to contain the shapes
        let topRect = NSRect(x: frame.minX + (itemPadding/2),
                             y: frame.maxY - itemHeight * 1.5,
                             width: itemWidth,
                             height: itemHeight)
        
        let bottomRect = NSRect(x: frame.minX + (itemPadding/2),
                             y: frame.maxY - (itemHeight * 1.5)*2 + 2,
                             width: itemWidth,
                             height: itemHeight)
        
        // Draw top shape (rounded rectangle)
        topLayer.frame = topRect
        topLayer.path = NSBezierPath(
            roundedRect: topLayer.bounds,
            xRadius: shapeRadius,
            yRadius: shapeRadius).CGPath
        //topLayer.opacity = 0.8
        topLayer.zPosition = CGFloat(0)
        
        // Draw bottom shape (rounded rectangle)
        bottomLayer.frame = bottomRect
        bottomLayer.path = NSBezierPath(
            roundedRect: bottomLayer.bounds,
            xRadius: shapeRadius,
            yRadius: shapeRadius).CGPath
        //bottomLayer.opacity = 0.8
        bottomLayer.zPosition = CGFloat(0)
        
        // Add sublayers for top and bottom shapes
        layer?.addSublayer(topLayer)
        layer?.addSublayer(bottomLayer)
        
        
        AppDelegate.onReadWrite.subscribe(on: self) { (data: (readPercentage: CGFloat, writePercentage: CGFloat)) in
            Swift.print("Got r/w info. read percentage is \(data.readPercentage)")
            
            self.scale(shapeLayer: self.topLayer, fromValue: self.scaleStart, toValue: CGFloat(1.5))
            //self.display()
        }
        
    }
    
    var started = false
    //// XXXX temp
    override func mouseDown(with event: NSEvent) {
        if started {
            Swift.print("already started")
            return
        }
        
        Swift.print("starting timer")
       // Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(throb), userInfo: nil, repeats: false)
        
    }
    /*
    func throb() {
        Swift.print("THROB")
        let topVal = (scaleStart...scaleEnd).random()
        
        scale(shapeLayer: topLayer, fromValue: scaleStart, toValue: topVal)
        
        let bottomVal = (scaleStart...scaleEnd).random()
        scale(shapeLayer: bottomLayer, fromValue: scaleStart, toValue: bottomVal)
    }
    */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func scale(shapeLayer: CAShapeLayer, fromValue: CGFloat, toValue: CGFloat) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = fromValue
        scale.toValue = toValue
        scale.duration = 0.25
        scale.autoreverses = false
        scale.delegate = self
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        shapeLayer.add(scale, forKey: fromValue < toValue ? "scaleUp" : "scaleDown")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        /*
        if flag {
            if let scaleAnim = anim as? CABasicAnimation,
                let fromValue = scaleAnim.fromValue as? CGFloat,
                let toValue = scaleAnim.toValue as? CGFloat {
                
                
                if fromValue < toValue {
                    Swift.print("Restarting \(toValue)")
                    
                    
                    scale(shapeLayer: topLayer, fromValue: toValue, toValue: scaleStart)
                } else {
                    Swift.print("DONE")
                    
                    started = false
                    //start()
                }
            }
        } */
    }

    override func draw(_ dirtyRect: NSRect) {
        self.topLayer.fillColor = NSColor.green.cgColor
        self.bottomLayer.fillColor = NSColor.red.cgColor
    }
}

public extension NSBezierPath {
    
    public var CGPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineToBezierPathElement: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveToBezierPathElement: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                                                control1: CGPoint(x: points[0].x, y: points[0].y),
                                                                control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
    }
}

extension ClosedRange where Bound : FloatingPoint {
    public func random() -> Bound {
        let range = self.upperBound - self.lowerBound
        let randomValue = (Bound(arc4random_uniform(UINT32_MAX)) / Bound(UINT32_MAX)) * range + self.lowerBound
        return randomValue
    }
}
