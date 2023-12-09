//
//  KodioApp.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `Scene` for the application
@main struct KodioApp: App {
    /// The AppState model
    @State private var appState: AppState = .shared
    /// The KodiConnector model
    @State private var kodi: KodiConnector = .shared
    /// The KodiPlayer model
    @State private var player: KodiPlayer = .shared
    /// The Browser model
    @State private var browser = BrowserModel()

#if os(macOS)
    /// Open new windows
    @Environment(\.openWindow)
    var openWindow
    /// AppKit app delegate
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    // MARK: Body of the Scene

    /// The body of the `Scene`
    var body: some Scene {
        Window("Kodio", id: "Main") {
            MainView()
                .environment(appState)
                .environment(kodi)
                .environment(player)
                .environment(browser)
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
                    .environment(appState)
                    .environment(kodi)
            }
        }
        /// The Kodio Settings
        Settings {
            SettingsView()
                .frame(width: 700, height: 500)
                .environment(appState)
                .environment(kodi)
        }
        /// Add Kodio to the Menu Bar
        MenuBarExtra("Kodio", systemImage: "k.square.fill") {
            MenuBarExtraView()
                .environment(kodi)
                .environment(player)
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
        }
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .defaultPosition(.center)
    }

#endif

#if os(visionOS)
    /// The body of the `Scene`
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(appState)
                .environment(kodi)
                .environment(player)
                .environment(browser)
                .task {
                    if kodi.status == .none {
                        /// Get the selected host (if any)
                        kodi.getSelectedHost()
                    }
                }
        }
        .defaultSize(width: 1920, height: 1080)
    }
#endif

#if os(iOS)
    /// The body of the `Scene`
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(appState)
                .environment(kodi)
                .environment(player)
                .environment(browser)
                .task {
                    if kodi.status == .none {
                        /// Get the selected host (if any)
                        kodi.getSelectedHost()
                    }
                }
        }
    }
#endif
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
