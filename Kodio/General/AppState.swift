//
//  AppState.swift
//  Kodio
//
//  Created by Nick Berendsen on 11/08/2022.
//

import Foundation
import SwiftlyKodiAPI

/// The class to observe the Kodio App state
class AppState: ObservableObject {
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// The Kodio settings
    @Published var settings: KodioSettings
    /// Items in the sidebar
    @Published var sidebar: [Router.Item] = []
    /// Init the class; get Kodio settings
    private init() {
        self.settings = KodioSettings.load()
    }
}

extension AppState {

    /// Check if a sidebar item is visible
    /// - Parameter route: The ``Router``
    /// - Returns: True or False
    func visible(route: Router) -> Bool {
        switch route {
        case .musicVideos:
            return settings.showMusicVideos
        default:
            return true
        }
    }
}

extension AppState {

    /// Update the Kodio settings
    /// - Parameter settings: The ``KodioSettings``
    @MainActor func updateSettings(settings: KodioSettings) {
        KodioSettings.save(settings: settings)
        self.settings = settings
    }
}

extension AppState {

    /// The state of  loading a View
    /// - Note: This `enum` is not used in this `class` but in Views that load items via a `Task`
    enum State {
        /// The Task is loading the items
        case loading
        /// No items where found by the `Task`
        case empty
        /// The `Task` is done and items where found
        case ready
    }
}
