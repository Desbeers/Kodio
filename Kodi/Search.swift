///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

extension KodiClient {
    struct SearchFields {
        var text = ""
        /// Search ID; Change on every refresh to speed-up the view
        var searchID = UUID().uuidString
    }

    func searchUpdate(text: String) {
        let appState = AppState.shared
        if text.isEmpty {
            DispatchQueue.main.async {
                self.search.text = ""
                appState.filter = self.previousFilter
            }
        } else {
            searchTimer?.invalidate()
            /// Set the timer
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
          DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            DispatchQueue.main.async {
                if appState.filter.songs != .search && !text.isEmpty {
                    /// Save the state before search
                    self!.previousFilter = appState.filter
                    /// Make sure the correct tabs are selected
                    appState.tabs.tabSidebar = .artists
                    appState.tabs.tabDetails = .songs
                    /// Set the view filter
                    appState.filter.artists = .search
                    appState.filter.songs = .search
                    appState.filter.albums = .search
                }
                /// Give the list a new ID so the view is faster
                self!.search.searchID = UUID().uuidString
                self!.search.text = text
            }
          }
        })
        }
    }
}
