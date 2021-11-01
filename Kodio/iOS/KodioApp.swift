//
//  KodioApp.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

@main
struct KodioApp: App {
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
    /// Keep an eye of our state; iOS doesn't like to go into the background while we have a websocket connection
    @Environment(\.scenePhase) var scenePhase
    /// Init the app; check on what platform we are running
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            AppState.shared.userInterface = .iPad
        } else if UIDevice.current.userInterfaceIdiom == .mac {
            AppState.shared.userInterface = .iPad
        } else {
            AppState.shared.userInterface = .iPhone
        }
    }
    /// The scene
    var body: some Scene {
        WindowGroup {
            ViewContent()
                .environmentObject(appState)
                .environmentObject(kodiHost)
                .environmentObject(library)
                .environmentObject(player)
                .environmentObject(kodiClient)
                .environmentObject(queue)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive {
                        logger("Inactive (iOS)")
                    } else if newPhase == .active {
                        logger("Active (iOS)")
                        if appState.state == .sleeping {
                            appState.state = .wakeup
                        }
                    } else if newPhase == .background {
                        logger("Background (iOS)")
                        appState.state = .sleeping
                    }
                }
        }
    }
}
