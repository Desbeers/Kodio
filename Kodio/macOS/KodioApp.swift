//
//  KodioApp.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The startpoint of the macOS application
@main struct KodioApp: App {
    /// The AppState model
    @StateObject var appState: AppState = .shared
    /// The KodiHost model
    @StateObject var kodiHost: KodiHost = .shared
    /// The Library model
    @StateObject var library: Library = .shared
    /// The Player model
    @StateObject var player: Player = .shared
    /// The Queue model
    @StateObject var queue: Queue = .shared
    /// App delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// The scene
    var body: some Scene {
        WindowGroup {
            ViewContent()
                .environmentObject(appState)
                .environmentObject(kodiHost)
                .environmentObject(library)
                .environmentObject(player)
                .environmentObject(queue)
        }
        /// Hide the title so we can use the whole toolbar for buttons
        /// - Note: the buttons will become smaller
        .windowStyle(HiddenTitleBarWindowStyle())
        /// Below will make the button size normal again; however, will also give
        /// the option to show only 'text' buttons and that makes no sense for Kodio
        /// .windowToolbarStyle(UnifiedWindowToolbarStyle())
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("Kodio Help") {
                    Task {
                        appState.viewSheet(type: .help)
                    }
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About Kodio") {
                    Task {
                        appState.viewSheet(type: .about)
                    }
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                ViewHostsMenu().environmentObject(appState)
            }
            CommandMenu("Host") {
                if appState.state == .loadedLibrary {
                    Button("Scan library on '\(appState.selectedHost.description)'") {
                        kodiHost.scanAudioLibrary()
                    }
                }
            }
            /// Show or hide the sidebar
            SidebarCommands()
            /// Toolbar commands
            ToolbarCommands()
        }
        Settings {
            /// - Note: The settings view does not 'get' the environment automatic
            ViewSettings()
                .environmentObject(appState)
        }
    }
}
