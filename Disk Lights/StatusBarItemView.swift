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
    
    let scaleDuration = CFTimeInterval(0.33)
    
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
        
        topLayer.strokeColor = NSColor.white.cgColor
        topLayer.zPosition = CGFloat(0)
        
        // Draw bottom shape (rounded rectangle)
        bottomLayer.frame = bottomRect
        bottomLayer.path = NSBezierPath(
            roundedRect: bottomLayer.bounds,
            xRadius: shapeRadius,
            yRadius: shapeRadius).CGPath
        
        bottomLayer.strokeColor = NSColor.white.cgColor
        bottomLayer.zPosition = CGFloat(0)
        
        // Add sublayers for top and bottom shapes
        layer?.addSublayer(topLayer)
        layer?.addSublayer(bottomLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func buildScaleAnimation() -> CABasicAnimation {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        
        scale.duration = scaleDuration
        scale.autoreverses = false
        scale.delegate = self
        scale.fillMode = kCAFillModeForwards
        scale.isRemovedOnCompletion = false
        
        return scale
    }
    
    // XXX
    override func mouseDown(with event: NSEvent) {
        DriveManager.sharedInstance.refresh()
    }
    
    /**
     Displays the read animation
     
     - Parameter fromValue:     From value
     - Parameter toValue:       To value
    */
    func readAnimation(fromValue: CGFloat, toValue: CGFloat) {
        let scale = buildScaleAnimation()
        scale.fromValue = fromValue
        scale.toValue = toValue
        
        topLayer.zPosition = CGFloat(1)
        bottomLayer.zPosition = CGFloat(0)
        topLayer.add(scale, forKey: fromValue < toValue ? "scaleUp" : "scaleDown")
    }
    
    /**
     Displays the write animation
     
     - Parameter fromValue:     From value
     - Parameter toValue:       To value
     */
    func writeAnimation(fromValue: CGFloat, toValue: CGFloat) {
        let scale = buildScaleAnimation()
        scale.fromValue = fromValue
        scale.toValue = toValue
        
        topLayer.zPosition = CGFloat(0)
        bottomLayer.zPosition = CGFloat(1)
        bottomLayer.add(scale, forKey: fromValue < toValue ? "scaleUp" : "scaleDown")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.topLayer.fillColor = NSColor.green.withAlphaComponent(0.5).cgColor
        self.bottomLayer.fillColor = NSColor.red.withAlphaComponent(0.5).cgColor
    }
}

