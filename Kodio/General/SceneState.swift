//
//  SceneState.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/08/2022.
//

import Foundation
import SwiftlyKodiAPI

/// The class to observe the current Kodio Scene state
class SceneState: ObservableObject {
    /// The current selection in the sidebar
    @Published var selection: Router? = .start
    /// The current search query
    var query: String = ""
}

extension SceneState {

    /// Update the serach
    /// - Parameter query: The search query
    @MainActor func updateSearch(query: String) async {
        do {
            try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
            self.query = query
            Task { @MainActor in
                if !query.isEmpty {
                    selection = .search
                } else if selection == .search {
                    /// Go to the main browser view; the search is canceled
                    selection = .library
                }
            }
        } catch { }
    }
}
