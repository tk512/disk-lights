//
//  StatusBarController.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/23/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Foundation
import Cocoa

class StatusBarController : NSObject {
    
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var statusItem = NSStatusBar.system().statusItem(withLength: 24)
    var settingsViewController: SettingsViewController?
    var subview: StatusBarItemView!
    
    var prevReadValue: CGFloat = 0.0
    var prevWriteValue: CGFloat = 0.0
    
    override func awakeFromNib() {

        if let button = statusItem.button {
            if subview == nil {
                subview = StatusBarItemView()
            }
            
            button.addSubview(subview)

            button.target = self
            button.action = #selector(StatusBarController.togglePopover(_:))
            
            func normalizeValue(_ percentage: UInt64) -> CGFloat {
                let scaleValue = (CGFloat(percentage)/100.0*1.0)+1.0
                Swift.print("Scaling to \(scaleValue)")
                return scaleValue
            }
            
            AppDelegate.onRead.subscribe(on: self) { (rate: UInt64) in
                let toValue = normalizeValue(rate)
                self.subview.readAnimation(fromValue: self.prevReadValue,
                                           toValue: toValue)
                self.prevReadValue = toValue
            }
            
            AppDelegate.onWrite.subscribe(on: self) { (rate: UInt64) in
                let toValue = normalizeValue(rate)
                self.subview.writeAnimation(fromValue: self.prevWriteValue,
                                           toValue: toValue)
                self.prevWriteValue = toValue
            }
        }
        
        statusItem.view?.display()
        
        if let settingsViewController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            
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
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
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
