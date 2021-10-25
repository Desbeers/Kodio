//
//  AppDelegate.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// App delegate class for macOS
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        /// Disallow window tabbing
        NSWindow.allowsAutomaticWindowTabbing = false
        /// Notifications
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
    }
    /// What to do when the mac goes to sleep and wakeup
    @objc private func sleepListener(_ aNotification: Notification) {
        if aNotification.name == NSWorkspace.willSleepNotification {
            AppState.shared.loadingState = .sleeping
        } else if aNotification.name == NSWorkspace.didWakeNotification {
            AppState.shared.loadingState = .wakeup
        }
    }
}
