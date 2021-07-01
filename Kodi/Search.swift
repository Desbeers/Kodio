///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation
import Combine

class SearchFieldObserver: ObservableObject {
    /// Use a shared instance
    static let shared = SearchFieldObserver()
    /// The search string
    @Published var searchText = ""
    var searchIsActive: Bool = false
    /// Magic stuff
    private var subscriptions = Set<AnyCancellable>()
    init() {
        $searchText
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .sink(receiveValue: { text in
                KodiClient.shared.searchQuery = text
                /// Change ID on every refresh to speed-up the view
                KodiClient.shared.searchID = UUID().uuidString
                if text.isEmpty {
                    self.searchIsActive = false
                    /// Back to opening state
                    AppState.shared.filter.albums = .compilations
                    AppState.shared.filter.songs = .compilations
                }
                if !self.searchIsActive, !text.isEmpty {
                    let appState = AppState.shared
                    /// Start the search
                    self.searchIsActive = true
                    appState.filter.albums = .none
                    appState.filter.songs = .none
                }
            })
            .store(in: &subscriptions)
    }
}

extension Array where Element == ArtistFields {
    func filterArtists() -> [Element] {
        if KodiClient.shared.searchQuery.isEmpty {
            return self
        } else {
            return self.filter { $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(KodiClient.shared.searchQuery)}
        }
    }
}

extension Array where Element == AlbumFields {
    func filterAlbums() -> [Element] {
        if AppState.shared.filter.albums == .none {
            return KodiClient.shared.albums.all.filter { $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(KodiClient.shared.searchQuery)}
        }
        return self
    }
}

extension Array where Element == SongFields {
    func filterSongs() -> [Element] {
        print("Filter Songs")
        if AppState.shared.filter.songs == .none {
            return KodiClient.shared.songs.all.filter { $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(KodiClient.shared.searchQuery)}
        }
        return self
    }
}
