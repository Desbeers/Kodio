//
//  AppDelegate.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// AppKit app delegate
class AppDelegate: NSObject, NSApplicationDelegate {

    /// Don't terminate when the last Kodi windo is closed
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        false
    }
}
