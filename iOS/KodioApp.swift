///
/// KodioApp.swift
/// Kodio (iOS)
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
    /// Keep an eye of our state; iOS doesn't like to go into the background while we have a websocket connection
    @Environment(\.scenePhase) var scenePhase
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            KodiClient.shared.userInterface = .iPad
        } else {
            KodiClient.shared.userInterface = .iPhone
        }
    }
    /// The view
    var body: some Scene {
        WindowGroup {
            ViewContent()
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: true)
                .environmentObject(kodi)
                .environmentObject(appState)
                .onAppear(
                    perform: {
                        kodi.log(#function, "onAppear (iOS)")
                    }
                )
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive {
                        kodi.log(#function, "Inactive (iOS)")
                    } else if newPhase == .active {
                        kodi.log(#function, "Active (iOS)")
                        kodi.connectWebSocket()
                        kodi.getLibraryDetails()
                    } else if newPhase == .background {
                        kodi.log(#function, "Background (iOS)")
                        kodi.disconnectWebSocket()
                    }
                }
        }
    }
}
