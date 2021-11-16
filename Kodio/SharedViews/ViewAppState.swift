//
//  ViewAppState.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the status of Kodio
struct ViewAppStateStatus: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiClient model
    @EnvironmentObject var kodiClient: KodiClient
    /// The view
    var body: some View {
        HStack {
            switch appState.state {
            case .noHostConfig:
                Text("Kodio is not configurated")
            case .none:
                Text("No host selected")
            case .connectedToHost:
                Text("Connected to '\(kodiClient.selectedHost.description)'")
            case .loadingLibrary:
                Text("Loading library")
                Spacer()
                ProgressView()
                /// Make this a bit smaller on macOS
                    .macOS {$0
                    .scaleEffect(0.5)
                    }
            case .loadedLibrary, .sleeping, .wakeup:
                Text("Music on '\(kodiClient.selectedHost.description)'")
            case .failure:
                Text("'\(kodiClient.selectedHost.description)' is not available")
            }
            Spacer()
        }
        .frame(height: 20)
    }
}
