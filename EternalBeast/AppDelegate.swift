//
//  AppDelegate.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // Reopen closed window when clicked on icon in dock
    // Source: https://stackoverflow.com/questions/39400795/os-x-app-doesnt-launch-new-window-on-dock-icon-press-in-swift
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window: AnyObject in sender.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }

}

