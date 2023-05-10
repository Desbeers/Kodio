//
//  AppDelegate.swift
//  Kodio
//
//  Created by Nick Berendsen on 30/04/2023.
//

import SwiftUI

/// AppKit app delegate
class AppDelegate: NSObject, NSApplicationDelegate {

    /// Don't terminate when the last Kodi windo is closed
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        false
    }
}
