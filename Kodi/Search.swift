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
                    Artists.shared.list = KodiClient.shared.artists.all
                    Albums.shared.filter = .compilations
                    Songs.shared.filter = .compilations
                }
                if !self.searchIsActive, !text.isEmpty {
                    /// Start the search
                    self.searchIsActive = true
                    Albums.shared.filter = .none
                    Songs.shared.filter = .none
                }
                if !text.isEmpty {
                    Artists.shared.list = KodiClient.shared.artists.all.filterArtists()
                    Albums.shared.list = KodiClient.shared.albums.all.filterAlbums()
                    Songs.shared.list = KodiClient.shared.songs.all.filterSongs()
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
        if Albums.shared.filter == .none {
            return self.filter { $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(KodiClient.shared.searchQuery)}
        }
        return self
    }
}

extension Array where Element == SongFields {
    func filterSongs() -> [Element] {
        if Songs.shared.filter == .none {
            return self.filter { $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(KodiClient.shared.searchQuery)}
        }
        return self
    }
}
