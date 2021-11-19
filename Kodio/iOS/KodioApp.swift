//
//  KodioApp.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The startpoint of the iOS application
@main struct KodioApp: App {
    /// The AppState model
    @StateObject var appState: AppState = .shared
    /// The Library model
    @StateObject var library: Library = .shared
    /// The Player model
    @StateObject var player: Player = .shared
    /// Keep an eye of our state; iOS doesn't like to go into the background while we have a websocket connection
    @Environment(\.scenePhase) var scenePhase
    /// Init the app; check on what platform we are running
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            appState.system = .iPad
        } else if UIDevice.current.userInterfaceIdiom == .mac {
            appState.system = .iPad
        } else {
            appState.system = .iPhone
        }
    }
    /// The scene
    var body: some Scene {
        WindowGroup {
            ViewContent()
                .environmentObject(appState)
                .environmentObject(library)
                .environmentObject(player)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive {
                        logger("Inactive (iOS)")
                        Task {
                            appState.setState(current: .sleeping)
                        }
                    } else if newPhase == .active {
                        logger("Active (iOS)")
                        if appState.state == .sleeping {
                            Task {
                                appState.setState(current: .wakeup)
                            }
                        }
                    } else if newPhase == .background {
                        logger("Background (iOS)")
                    }
                }
        }
    }
}
