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
                self.filter = self.previousFilter
            }
        } else {
            searchTimer?.invalidate()
            /// Set the timer
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
          DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            DispatchQueue.main.async {
                if self?.filter.songs != .search && !text.isEmpty {
                    /// Save the state before search
                    self!.previousFilter = self!.filter
                    /// Make sure the correct tabs are selected
                    appState.tabs.tabArtistGenre = .artists
                    appState.tabs.tabSongPlaylist = .songs
                    /// Set the view filter
                    self!.filter.artists = .search
                    self!.filter.songs = .search
                    self!.filter.albums = .search
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
