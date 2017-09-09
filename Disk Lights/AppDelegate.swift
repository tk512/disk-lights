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
    
    static let onReadWrite = Signal<(readPercentage: CGFloat, writePercentage: CGFloat)>()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("App did finish launching")
        // Handle dark mode in macOS
        initDarkModeHandler()
        
        // XXX
        Timer.scheduledTimer(timeInterval: 2,
                             target: self,
                             selector: #selector(animateActivity),
                             userInfo: nil,
                             repeats: true)
    }
    
    func animateActivity() {
        print("getting read/write percentages")
        
        AppDelegate.onReadWrite.fire((readPercentage: CGFloat(2.5), writePercentage: CGFloat(1.0)))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
}

