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
    }
}
