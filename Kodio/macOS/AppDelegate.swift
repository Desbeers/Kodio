//
//  AppDelegate.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// App delegate class for macOS
///
/// Not everything is possible in 'pure' SwiftUI yet; I hope one day this class is not needed anymore
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// Some settings after the application is started
    ///  - Disallow window tabbing
    ///  - Add a notification for sleeping and wakeup
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /// Disallow window tabbing
        NSWindow.allowsAutomaticWindowTabbing = false
        /// Notifications
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(sleepListener(_:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
    }
    /// What to do when the Mac goes to sleep and wakeup again
    @objc private func sleepListener(_ aNotification: Notification) {
        let appState: AppState = .shared
        if aNotification.name == NSWorkspace.willSleepNotification {
            Task {
                await appState.setState(current: .sleeping)
            }
        } else if aNotification.name == NSWorkspace.didWakeNotification {
            Task {
                await appState.setState(current: .wakeup)
            }
        }
    }
}
