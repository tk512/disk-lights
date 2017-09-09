//
//  StatusBarImage.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 8/13/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa

class StatusBarImage: NSImage {

    override func draw(in rect: NSRect) {
        super.draw(in: rect)
        
    
        backgroundColor = NSColor.yellow
    }
}
