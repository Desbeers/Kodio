///
/// KodioApp.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

@main
struct KodioApp: App {
    /// The object that has it all
    @StateObject var kodi = KodiClient.shared
    /// State of application
    @StateObject var appState = AppState.shared
    /// AppDelegate is needed to keep an eye on sleeping
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// The scene
    var body: some Scene {
        WindowGroup {
            ViewContent()
                .environmentObject(kodi)
                .environmentObject(appState)
                .navigationTitle(kodi.player.navigationTitle)
                .navigationSubtitle(kodi.player.navigationSubtitle)
        }
        Settings {
            ViewKodiEditHosts()
                .frame(width: 520)
                .environmentObject(kodi)
                .environmentObject(appState)
        }
        .commands {
            MenuCommands(kodi: kodi, appState: appState)
            /// Add the SideBar menu
            SidebarCommands()
        }
    }
}

/// Menu commands for macOS
/// - Note: Commands do not like ObservalbleObjects
struct MenuCommands: Commands {
    /// The object that has it all
    var kodi: KodiClient
    /// State of the application
    var appState: AppState
    var body: some Commands {
        CommandMenu("Host") {
            Button("Scan Library") {
                kodi.scanAudioLibrary()
            }
            .disabled(kodi.libraryIsScanning)
            Divider()
            Button("Quit Kodi") {
                kodi.applicationQuit()
            }
        }
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            ViewKodiHostsMenu().environmentObject(kodi).environmentObject(appState)
        }
        CommandGroup(after: CommandGroupPlacement.toolbar) {
            MenuViewGroup()
        }
        /// - ToDo: Correct URL when published
        CommandGroup(replacing: CommandGroupPlacement.help) {
            Button("Open on GitHub") {
                if let url = URL(string: "http://github.com/desbeers/kodio") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
}

/// CommandGroup as used in KodioApp does not update its state when directly added to .commands
/// It works when it is added as a View like this
/// - Note: https://stackoverflow.com/questions/65768096/how-to-activate-deactivate-menu-items-in-swiftui

struct MenuViewGroup: View {
    @AppStorage("ShowLog") var showLog: Bool = false
    /// The view
    var body: some View {
        Button(showLog ? "Hide Console Messages" : "Show Console Messages") {
            withAnimation {
                showLog.toggle()
            }
        }
    }
}
