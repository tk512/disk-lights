//
//  DriveManager.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/18/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation
import Cocoa

class DriveManager {
   // let statusBarManager: StatusBarManager
    //let popover: NSPopover
    //var statusItem: NSStatusItem
    //var eventMonitor: EventMonitor?
    
    var driveNodes: [String:DriveData] = [:]
    var drivesEnabled: [String:Bool] = [:]
    
    func disabled() {
        
        //self.statusBarManager = StatusBarManager()
        //self.popover =
        
        // XXX Initialize IO Kit
        // initIOKit()
        
        // Take the drive nodes data and match up with drives enabled
        // XXX
        
        // Create status bar items
        
        //statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        
     //   if let button = statusItem.button {
      //      button.image = NSImage(named: "StatusBarButtonImage")
       //     button.action = #selector(togglePopover(sender:))
       // }
        
        // Ensure that when we click away, the main window closes
        //eventMonitor?.start()
        
        // The event monitor ensures that when we click outside the popover, it closes
     //   eventMonitor = EventMonitor(mask: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown]) { [unowned self] event in
     //       if self.popover.isShown {
     //           self.closePopover(sender: event)
      //      }
       // }
    }
}
