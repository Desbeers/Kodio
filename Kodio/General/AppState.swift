//
//  AppState.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import Foundation
import SwiftlyKodiAPI

/// The class to observe the Kodio App state
class AppState: ObservableObject {
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// The Kodio settings
    @Published var settings: KodioSettings
    /// The current selection in the sidebar
    @Published var selection: Router = .start
    /// The current search query
    var query: String = ""
    /// Init the class; get Kodio settings
    private init() {
        self.settings = KodioSettings.load()
    }
}

extension AppState {

    /// Update the search query
    /// - Parameter query: The search query
    @MainActor func updateSearch(query: String) async {
        do {
            try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
            self.query = query
                if !query.isEmpty {
                    selection = .search
                } else if selection == .search {
                    /// Go to the main browser view; the search is canceled
                    selection = .library
                }
        } catch { }
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
