//
//  ViewAppState.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewAppStateStatus: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiClient model
    @EnvironmentObject var kodiClient: KodiClient
    /// The view
    var body: some View {
        HStack {
            switch appState.loadingState {
            case .noConfig:
                Text("Kodio is not configurated")
            case .none:
                Text("No host selected")
            case .connected:
                Text("Connected to '\(kodiClient.selectedHost.description)'")
            case .loading:
                Text("Loading library")
                Spacer()
                ProgressView()
#if os (macOS)
                    .scaleEffect(0.5)
#endif
            case .loaded, .sleeping, .wakeup:
                Text("Music on '\(kodiClient.selectedHost.description)'")
            case .failure:
                Text("'\(kodiClient.selectedHost.description)' is not available")
            }
            Spacer()
        }
        .frame(height: 20)
    }
}
