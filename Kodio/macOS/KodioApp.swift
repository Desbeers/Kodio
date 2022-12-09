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
    /// The View
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(kodi)
                .environmentObject(player)
                .task(id: appState.host) {
                    if let host = appState.host {
                        if kodi.state == .none {
                            kodi.connect(host: host.details)
                        }
                    }
                }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .commands {
            /// Show or hide the sidebar
            SidebarCommands()
            /// Toolbar commands
            ToolbarCommands()
            /// Rplace `Help`
            CommandGroup(replacing: .help) {
                Button("Help") {
                    openWindow(value: Window.help)
                }
            }
            /// Replace ``About``
            CommandGroup(replacing: .appInfo) {
                Button("About Kodio") {
                    openWindow(value: Window.about)
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
        WindowGroup("Window", for: Window.self) { $item in
            ZStack {
                switch item {
                case .about:
                    AboutView()
                case .help:
                    HelpView()
                case .none:
                    EmptyView()
                }
            }
            .background(Color("Window"))
            .withHostingWindow { window in
                if let window = window?.windowController?.window {
                    window.setPosition(vertical: .center, horizontal: .center, padding: 0)
                }
            }
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        /// Open a Video Window
        WindowGroup("Player", for: Video.Details.MusicVideo.self) { $item in
            /// Check if `item` isn't `nil`
            if let item = item {
                KodiPlayerView(video: item)
                    .withHostingWindow { window in
                        if let window = window?.windowController?.window {
                            window.setPosition(vertical: .center, horizontal: .center, padding: 0)
                        }
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

extension KodioApp {

    /// The kind of Windows Kodio can open
    enum Window: String, Codable {
        case about = "About Kodio"
        case help = "Help"
    }
}
