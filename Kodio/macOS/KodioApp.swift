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
                    appState.activeSheet = .help
                    appState.showSheet = true
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About Kodio") {
                    appState.activeSheet = .about
                    appState.showSheet = true
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                ViewHostsMenu().environmentObject(kodiClient).environmentObject(appState)
            }
            CommandMenu("Host") {
                if appState.state == .loadedLibrary {
                    Button("Scan library on '\(kodiClient.selectedHost.description)'") {
                        withAnimation {
                            kodiHost.scanAudioLibrary()
                        }
                    }
                }
            }
            /// Show or hide the sidebar
            SidebarCommands()
        }
        Settings {
            ViewSettings()
                .environmentObject(kodiClient)
        }
    }
}
