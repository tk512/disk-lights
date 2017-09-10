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

    @IBOutlet weak var statusBarController: StatusBarController!
    static var darkMode: Bool = false

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
    
    static let onRead = Signal<(start: CGFloat, end: CGFloat)>()
    static let onWrite = Signal<(start: CGFloat, end: CGFloat)>()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("App did finish launching")
        // Handle dark mode in macOS
        initDarkModeHandler()
        
        /*// XXX
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(animateReads),
                             userInfo: nil,
                             repeats: true)
        
        Timer.scheduledTimer(timeInterval: 1.5,
                             target: self,
                             selector: #selector(animateWrites),
                             userInfo: nil,
                             repeats: true)
        */
        
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(processDiskData),
                             userInfo: nil,
                             repeats: true)
    }
    
    func processDiskData() {
        DriveManager.sharedInstance.refresh()
    }
    
    
    var x = 0, y = 0
    func animateReads() {
        
        x += 1
        switch x {
        case 1:
            AppDelegate.onRead.fire((start: CGFloat(1.0), end: CGFloat(2.0)))
        case 2:
            AppDelegate.onRead.fire((start: CGFloat(2.0), end: CGFloat(1.0)))
        case 3:
            AppDelegate.onRead.fire((start: CGFloat(1.0), end: CGFloat(2.5)))
        case 4:
            AppDelegate.onRead.fire((start: CGFloat(2.5), end: CGFloat(1.5)))
        case 5:
            AppDelegate.onRead.fire((start: CGFloat(1.5), end: CGFloat(1.0)))
        default:
            x = 0
        }
    }
    
    func animateWrites() {
        
        y += 1
        switch y {
        case 1:
            AppDelegate.onWrite.fire((start: CGFloat(1.0), end: CGFloat(2.0)))
        case 2:
            AppDelegate.onWrite.fire((start: CGFloat(2.0), end: CGFloat(1.0)))
        case 3:
            AppDelegate.onWrite.fire((start: CGFloat(1.0), end: CGFloat(2.5)))
        case 4:
            AppDelegate.onWrite.fire((start: CGFloat(2.5), end: CGFloat(1.5)))
        case 5:
            AppDelegate.onWrite.fire((start: CGFloat(1.5), end: CGFloat(1.0)))
        default:
            y = 0
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
}

