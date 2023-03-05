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
    /// Bool to show or hide a SwiftUI sheet
    @Published var showSheet: Bool = false
    /// Bool to show or hide a SwiftUI fullScreenCover
    @Published var showFullScreenCover: Bool = false
    /// The Music Video to show full screen
    var activeMusicVideo: (any KodiItem)?
    /// Define what kind of sheet to show
    var activeSheet: Sheets = .about
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

extension SceneState {

    // MARK: Sheets for Kodio

    /// View a SwiftUI sheet
    /// - Parameter type: One of the ``Sheets``.
    @MainActor func viewSheet(type: Sheets) {
        activeSheet = type
        showSheet = true
    }

    /// View a SwiftUI full screen movie
    /// - Parameter type: One of the ``Sheets``.
    func viewMusicVideo(item: any KodiItem) {
        activeMusicVideo = item
        showFullScreenCover = true
    }

    /// The different kind of sheets Kodio can present
    enum Sheets {
        /// Show the `Settings` sheet
        case settings
        /// Show the `About` sheet
        case about
        /// Show the `Help` sheet
        case help
    }
}
