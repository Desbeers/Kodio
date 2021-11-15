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
    /// The KodiClient model
    @StateObject var kodiClient: KodiClient = .shared
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
                .navigationTitle(player.title)
                .navigationSubtitle(player.artist)
                .environmentObject(appState)
                .environmentObject(kodiHost)
                .environmentObject(kodiClient)
                .environmentObject(library)
                .environmentObject(player)
                .environmentObject(queue)
        }
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
                ViewHostsMenu().environmentObject(kodiClient).environmentObject(appState)
            }
            CommandMenu("Host") {
                if appState.state == .loadedLibrary {
                    Button("Scan library on '\(kodiClient.selectedHost.description)'") {
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
            ViewSettings()
                .environmentObject(kodiClient)
        }
    }
}
