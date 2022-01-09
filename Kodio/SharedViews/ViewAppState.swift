//
//  ViewAppState.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// View the status of Kodio
struct ViewAppStateStatus: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        HStack {
            switch appState.state {
            case .noHostConfig:
                Text("Kodio has no hosts")
            case .none:
                Text("No host selected")
            case .connectedToHost:
                Text("Connected to '\(appState.selectedHost.description)'")
            case .loadingLibrary:
                ProgressView()
                /// Make this a bit smaller on macOS
                    .macOS {$0
                    .scaleEffect(0.5)
                    }
                /// And a bit of padding for iOS
                    .iOS {$0
                    .padding(.trailing, 4)
                    }
                Text("Loading library")
            case .loadedLibrary, .sleeping, .wakeup:
                Text("Music on '\(appState.selectedHost.description)'")
            case .failure:
                Text("'\(appState.selectedHost.description)' is not available")
            }
        }
        .frame(height: 20)
    }
}
