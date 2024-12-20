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
    @State private var appState = AppState()
    /// The KodiConnector model
    @State private var kodi = KodiConnector()
    /// The Browser model
    @State private var browser = BrowserModel()
    /// The Help model
    @State private var help = HelpModel()
    /// Open new windows
    @Environment(\.openWindow) var openWindow
    /// AppKit app delegate
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    // MARK: Body of the Scene

    /// The body of the `Scene`
    var body: some Scene {
        Window("Kodio", id: "Main") {
            MainView()
                .environment(appState)
                .environment(kodi)
                .environment(browser)
                .environment(help)
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
                Button("Kodio Help") {
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
                .environment(help)
        }
        /// Add Kodio to the Menu Bar
        MenuBarExtra("Kodio", systemImage: "k.square.fill") {
            MenuBarExtraView()
                .environment(kodi)
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
                        .environment(help)
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
}

extension KodioApp {

    /// The kind of Windows Kodio can open
    enum Windows: String, Codable {
        /// About `View`
        case about = "About Kodio"
        /// Help `View`
        case help = "Kodio Help"
    }
}
