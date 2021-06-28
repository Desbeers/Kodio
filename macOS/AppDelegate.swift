///
/// AppDelegate.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBar: MenuBarController?
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /// Hide tabs related stuff in the menu
        NSWindow.allowsAutomaticWindowTabbing = false
        /// Notifications
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        /// Menu Bar
        let viewMenuBar = ViewMenuBar()
        let content = NSHostingView(rootView: viewMenuBar)
        content.frame = NSRect(x: 0, y: 0, width: 320, height: 120)
        menuBar = MenuBarController(content)
    }

    @objc private func sleepListener(_ aNotification: Notification) {
        if aNotification.name == NSWorkspace.willSleepNotification {
            KodiClient.shared.log(#function, "Going to sleep (macOS)")
        } else if aNotification.name == NSWorkspace.didWakeNotification {
            KodiClient.shared.log(#function, "Woke up (macOS)")
            KodiClient.shared.getLibraryDetails()
        }
    }
}
