//
//  AppDelegate.swift
//  Disk Lights
//
//  Created by Torbjørn Kristoffersen on 4/9/17.
//  Copyright © 2017 Torbjørn Kristoffersen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    static var darkMode: Bool = false
    var eventMonitor: EventMonitor?
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let popover = NSPopover()
    
    func getDarkMode() -> Bool {
        if let _ = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
            return true
        } else {
            return false
        }
    }
    
    func darkModeChanged(sender: NSNotification) {
        AppDelegate.darkMode = getDarkMode()
    }

    func initDarkModeHandler() {
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(darkModeChanged(sender:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        AppDelegate.darkMode = getDarkMode()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(togglePopover(sender:))
        }
        
        popover.contentViewController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "SettingsViewController") as? NSViewController
        
        // The event monitor ensures that when we click outside the popover, it closes
        eventMonitor = EventMonitor(mask: [NSEventMask.leftMouseDown, NSEventMask.rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        // Ensure that when we click away, the main window closes
        eventMonitor?.start()
        
        // Handle dark mode in macOS
        initDarkModeHandler()
     // XXX   initIOKit()
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        
        eventMonitor?.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        
        eventMonitor?.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

