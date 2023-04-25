//
//  KodioApp.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Scenes for Kodio
@main struct KodioApp: App {
    /// The AppState model
    @StateObject var appState: AppState = .shared
    /// The KodiConnector model
    @StateObject var kodi: KodiConnector = .shared
    /// The KodiPlayer model
    @StateObject var player: KodiPlayer = .shared
    /// Open new windows
    @Environment(\.openWindow) var openWindow

    // MARK: Body of the Scene

    /// The body of the `View`
    var body: some Scene {
        Window("Kodio", id: "Main") {
            MainView()
                .environmentObject(appState)
                .environmentObject(kodi)
                .environmentObject(player)
                .task {
                    if kodi.status == .none {
                        /// Get the selected host (if any)
                        kodi.getSelectedHost()
                    }
                }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .defaultSize(width: 1000, height: 800)
        .commands {
            /// Show or hide the sidebar
            SidebarCommands()
            /// Toolbar commands
            ToolbarCommands()
            /// Replace `New`
            CommandGroup(replacing: .newItem) {
                Button("New Window") {
                    openWindow(id: "Main")
                }
            }
            /// Replace `Help`
            CommandGroup(replacing: .help) {
                Button("Help") {
                    openWindow(value: Windows.help)
                }
            }
            /// Replace ``About``
            CommandGroup(replacing: .appInfo) {
                Button("About Kodio") {
                    openWindow(value: Windows.about)
                }
            }
            /// Add a `Host` menu
            CommandMenu("Host") {
                PartsView.HostSelector()
                    .environmentObject(appState)
                    .environmentObject(kodi)
            }
        }
        /// The Kodio Settings
        Settings {
            SettingsView()
                .frame(width: 700, height: 500)
                .environmentObject(appState)
                .environmentObject(kodi)
        }
        /// Add Kodio to the Menu Bar
        MenuBarExtra("Kodio", systemImage: "k.square.fill") {
            MenuBarExtraView()
                .environmentObject(kodi)
        }
        .menuBarExtraStyle(.window)
        /// Open new Windows
        WindowGroup("Window", for: Windows.self) { $item in
            ZStack {
                switch item {
                case .about:
                    AboutView()
                case .help:
                    HelpView()
                case .none:
                    AboutView()
                }
            }
            .background(Color("Window"))
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .defaultPosition(.center)
    }
}

extension KodioApp {

    /// The kind of Windows Kodio can open
    enum Windows: String, Codable {
        /// About `View`
        case about = "About Kodio"
        /// Help `View`
        case help = "Help"
    }
}
