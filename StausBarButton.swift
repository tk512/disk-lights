//
//  StausBarButton.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 8/13/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa

class StausBarButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        var path = NSBezierPath(ovalIn: dirtyRect)
        NSColor.green.setFill()
        path.fill()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
