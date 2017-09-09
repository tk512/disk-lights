//
//  StatusBarController.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/23/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation
import Cocoa

protocol StatusBarDelegate {
    func test()
}

class StatusBarController : NSObject, StatusBarDelegate {
    
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var statusItem = NSStatusBar.system().statusItem(withLength: 24)
    var settingsViewController: SettingsViewController?
    var subview: NSView!
    
    override init() {
        Swift.print("XYZ")
        
    }
    override func awakeFromNib() {

        Swift.print("subview=\(subview)")
        if let button = statusItem.button {
            if subview == nil {
                subview = StatusBarItemView()
            }
            button.addSubview(subview)

            button.target = self
            button.action = #selector(StatusBarController.togglePopover(_:))
        }
        
        statusItem.view?.display()
        
        if let settingsViewController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settingsViewController.statusBarDelegate = self
            popover.contentViewController = settingsViewController as NSViewController
        }
        
        // The event monitor ensures that when we click outside the popover, it closes
        eventMonitor = EventMonitor(mask: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(_: event)
            }
        }
        eventMonitor?.start()
    }
    
    func test() {
        print("Ran test via delegate")
        if let button = statusItem.button {
            button.image = NSImage(named: "Discoball")
        }
    }
    
    func showPopover(_ sender: AnyObject?) {
        /*if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }*/
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        
        eventMonitor?.stop()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(_: sender)
        } else {
            showPopover(_: sender)
        }
    }
}
