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
    /// All the items for this View
    @Published var items = Media()
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
    /// Te optional search query
    let query: String
    /// Init the model with the current ``Router``
    init(router: Router, query: String) {
        self.router = router
        self.query = query
    }
    
}

extension BrowserModel {
    
    /// The media to show in the ``BrowserView``
    struct Media: Equatable {
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
    func filterLibrary() {
        /// Set the state
        state = state == .ready ? .ready : .loading
        /// Get the shared KodiConnector
        let kodi: KodiConnector = .shared
        
        /// Get all songs from the library
        let songs = kodi.library.songs.sorted { $0.displayArtist < $1.displayArtist }
        /// Filter the songs
        switch router {
        case .recentlyAdded:
            library.songs = Array(
                songs.sorted {
                        $0.dateAdded > $1.dateAdded
                    }
                    .prefix(100)
            )
        case .recentlyPlayed:
            library.songs = Array(
                songs.filter {
                    $0.playcount > 0
                }.sorted {
                    $0.lastPlayed > $1.lastPlayed
                }
                    .prefix(100)
            )
        case .mostPlayed:
            library.songs = Array(
                songs.filter {
                    $0.playcount > 0
                }.sorted {
                    $0.playcount > $1.playcount
                }
                    .prefix(100)
            )
        case .favorites:
            library.songs = songs
                .filter {
                    $0.userRating > 0
                }
                .sorted {
                    $0.userRating > $1.userRating
                }
        case .search:
            library.songs = songs.search(query)
        default:
            library.songs = songs
        }
        
        if library.songs.isEmpty {
            state = .empty
        } else {
            
            /// All albums in the browser
            let songAlbums = library.songs.map({ $0.albumID })
            library.albums = kodi.library.albums.filter({songAlbums.contains($0.albumID)}).sorted { $0.displayArtist < $1.displayArtist }
            /// All artists in the browser
            let songArtists = library.songs.flatMap({ $0.albumArtistID }).removingDuplicates()
            library.artists = kodi.library.artists.filter({songArtists.contains($0.artistID)}).sorted { $0.sortByTitle < $1.sortByTitle }
            /// All genres in the browser
            let songGenres = library.songs.flatMap({ $0.genreID }).removingDuplicates()
            library.genres = kodi.library.audioGenres.filter({songGenres.contains($0.genreID)})
            /// Filter the browser based on selection
            filterBrowser()
            /// Set the state
            state = .ready
        }
    }
    
    /// Filter the ``BrowserView`` based on the optional ``BrowserModel/selection-swift.property``
    func filterBrowser() {
        var artists = library.artists
        var albums = library.albums
        var songs = library.songs
        if let genre = selection.genre {
            songs = songs.filter({$0.genreID.contains(genre.genreID)})
            albums = albums.filter({$0.genre.contains(genre.title)})
            let songArtists = songs.flatMap({ $0.albumArtistID }).removingDuplicates()
            artists = artists.filter({songArtists.contains($0.artistID)}).sorted { $0.title < $1.title }
        }
        if let artist = selection.artist {
            songs = songs.filter({$0.albumArtistID.contains(artist.artistID)}).sorted { $0.title < $1.title }
            albums = albums.filter({$0.artistID.contains(artist.artistID)}).sorted { $0.year < $1.year }
        }
        
        if let album = selection.album {
            songs = songs.filter({$0.albumID == album.albumID}).sorted { $0.track < $1.track }
        }
        items = Media(genres: library.genres, artists: artists, albums: albums, songs: songs)
    }
}
