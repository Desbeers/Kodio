//
//  BrowserModel.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/07/2022.
//

import Foundation
import SwiftlyKodiAPI

/// The model for ``BrowserView``
class BrowserModel: ObservableObject {
    /// The selection of optional genre, artist or album in the ``BrowserView``
    @Published var selection = Selection()
    /// The state of loading the songs
    @Published var state: AppState.State = .loading
    /// Details for the 'highest selected item'
    var details: (any KodiItem)? {
        if let album = selection.album {
            return album
        }
        if let artist = selection.artist {
            return artist
        }
        return nil
    }
    /// All the items that are available
    var library = Media()
    /// The current ``Router`` selection
    let router: Router
    /// The optional search query
    let query: String
    /// Init the model with the current ``Router``
    init(router: Router, query: String) {
        self.router = router
        self.query = query
    }
}

extension BrowserModel {

    /// The media to show in the ``BrowserView``
    struct Media: Equatable, Sendable {
        /// All genres
        var genres: [Library.Details.Genre] = []
        /// All martists
        var artists: [Audio.Details.Artist] = []
        /// All albums
        var albums: [Audio.Details.Album] = []
        /// All songs
        var songs: [Audio.Details.Song] = []
    }

    /// The optional selection in the ``BrowserView``
    struct Selection: Equatable, Hashable {
        /// Currently selected genre
        var genre: Library.Details.Genre?
        /// Currently selected artist
        var artist: Audio.Details.Artist?
        /// Currently selected album
        var album: Audio.Details.Album?
    }
}

extension BrowserModel {

    /// Filter the library by ``Router`` selection
    ///
    /// The browser library is based on songs; they are filtered first and then the rest is added
    func filterLibrary() async {

        /// Get the shared KodiConnector
        let kodi: KodiConnector = .shared

        /// Calculate past date
        let date = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pastDate = dateFormatter.string(from: date)

        /// Filter the songs
        switch router {
        case .compilations:
            let compilationAlbums = kodi.library.albums.filter({ $0.compilation == true }).map { $0.albumID }
            library.songs = kodi.library.songs
                .filter {
                    compilationAlbums.contains($0.albumID)
                }
                .sorted {
                    $0.sortByTitle < $1.sortByTitle
                }
        case .recentlyAdded:
            library.songs = kodi.library.songs
                .filter {
                    $0.dateAdded > pastDate
                }
                .sorted {
                    $0.dateAdded > $1.dateAdded
                }
        case .recentlyPlayed:
            library.songs = kodi.library.songs
                .filter {
                    $0.playcount > 0 && $0.lastPlayed > pastDate
                }
                .sorted {
                    $0.lastPlayed > $1.lastPlayed
                }
        case .mostPlayed:
            library.songs = Array(
                kodi.library.songs.filter {
                    $0.playcount > 0
                }
                    .sorted {
                        $0.playcount > $1.playcount
                    }
                    .prefix(1000)
            )
        case .favorites:
            library.songs = kodi.library.songs
                .filter {
                    $0.userRating >= AppState.shared.settings.userRating
                }
                .sorted {
                    $0.userRating > $1.userRating
                }
        case .search:
            library.songs = kodi.library.songs.search(query)
        default:
            library.songs = kodi.library.songs
                .sorted {
                    $0.displayArtist < $1.displayArtist
                }
        }
        if !library.songs.isEmpty {

            /// All albums in the browser
            let songAlbumIDs = Set(library.songs.map { $0.albumID })
            library.albums = kodi.library.albums
                .filter { songAlbumIDs.contains($0.albumID) }
                .sorted {
                    $0.displayArtist == $1.displayArtist ? $0.year < $1.year : $0.displayArtist < $1.displayArtist
                }

            /// All artists in the browser
            let songArtistIDs = Set(library.songs.flatMap { $0.albumArtistID })
            library.artists = kodi.library.artists
                .filter { songArtistIDs.contains($0.artistID) }
                .sorted { $0.sortByTitle < $1.sortByTitle }

            /// All genres in the browser
            let songGenreIDs = Set(library.songs.flatMap { $0.genreID })
            library.genres = kodi.library.audioGenres
                .filter { songGenreIDs.contains($0.genreID) }
        }
    }

    /// Filter the ``BrowserView`` based on the optional ``BrowserModel/Selection-swift.struct``
    func filterBrowser() async -> Media {
        var artists = library.artists
        var albums = library.albums
        var songs = library.songs

        /// Filter by genre
        if let genre = selection.genre {
            songs = songs
                .filter { $0.genreID.contains(genre.genreID) }
            albums = albums
                .filter { $0.genre.contains(genre.title) }
            let songArtistIDs = Set(songs.flatMap { $0.albumArtistID })
            artists = artists
                .filter { songArtistIDs.contains($0.artistID) }
        }

        /// Filter by artist
        if let artist = selection.artist {
            songs = songs
                .filter { $0.albumArtistID.contains(artist.artistID) }
            albums = albums
                .filter { $0.artistID.contains(artist.artistID) }
        }

        /// Filter by album
        if let album = selection.album {
            songs = songs
                .filter { $0.albumID == album.albumID }
                .sorted { $0.track < $1.track }
        }

        /// return the filtered items
        return Media(
            genres: library.genres,
            artists: artists,
            albums: albums,
            songs: songs
        )
    }
}
