///
/// AppDelegate.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /// Hide tabs related stuff in the menu
        NSWindow.allowsAutomaticWindowTabbing = false
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
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
