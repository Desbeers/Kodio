//
//  LibraryLoad.swift
//  Kodio
//
//  Created by Nick Berendsen on 06/11/2021.
//

import Foundation

extension Library {
 
    // MARK: - Loading library
    
    /// Get all music items from the library
    /// - Parameter reload: Bool; force a reload or else it will try to load it from the  cache
    /// - Returns: It will update the KodiClient variables
    func getLibrary(reload: Bool = false) {
        if reload {
            resetLibrary()
        }
        getRadioStations()
        libraryLists.all = getLibraryLists()
        libraryLists.selected = libraryLists.all.first!
        DispatchQueue.main.async {
            AppState.shared.state = .loadingLibrary
        }
        /// get media items
        Task(priority: .high) {
            /// Artists
            async let artists = getArtists(reload: reload)
            status.artists = await artists
            /// Albums
            async let albums = getAlbums(reload: reload)
            status.albums = await albums
            /// Genres
            async let genres = getGenres(reload: reload)
            status.genres = await genres
            /// Playlists
            async let playlists = getPlaylistsFiles()
            status.playlists = await playlists
            /// Songs
            if await albums {
                status.songs = await getSongs(reload: reload)
                /// Now load stuff depending on the songs
                status.libraryLists = await getLibraryListItems()
                /// Check if the library is still up to date
                if !reload {
                    await getLastUpdate()
                }
            }
        }
    }
    
    /// Check the loading status
    /// - Parameter status: The status enum that was set
    func checkStatus(status: Status) {
        if status.all, AppState.shared.state != .loadedLibrary {
            logger("Library is loaded")
            DispatchQueue.main.async {
                AppState.shared.state = .loadedLibrary
            }
        }
    }
    
    /// Reset the  library to its initial state
    func resetLibrary() {
        status.reset()
        selection = LibraryListItem()
        filteredContent = FilteredContent()
        playlists.files = []
        libraryLists.all = []
        libraryLists.selected = LibraryListItem()
        radioStations = []
        Player.shared.properties = Player.Properties()
        Player.shared.item = Player.PlayerItem()
    }

    /// The loading states of the library items
    struct Status {
        /// Check if all media items are loaded
        var all: Bool {
            if artists, albums, songs, libraryLists, genres, playlists {
                return true
            }
            return false
        }
        /// Loading state of the artists
        var artists: Bool = false
        /// Loading state of the albums
        var albums: Bool = false
        /// Loading state of the songs
        var songs: Bool = false
        /// Loading state of the genres
        var genres: Bool = false
        /// Loading state of the library list items
        var libraryLists: Bool = false
        /// Loading state of the playlists
        var playlists: Bool = false
        /// Loading state of the playing queue
        var queue: Bool = false
        /// Check if the library is up to date
        var upToDate: Bool = false
        /// Function to reset all states to initial value
        mutating func reset() {
            self = Status()
        }
    }

    /// The types of media in the library
    enum MediaType: String {
        /// An empty type
        case none = "None"
        /// An ``ArtistItem``
        case artist = "Artists"
        /// An ``AlbumItem``
        case album = "Albums"
        /// A ``SongItem``
        case song = "Songs"
        /// An ``GenreItem``
        case genre = "Genres"
        /// An ``LibrayListItem`` for  songs by album artists
        case albumArtists = "Album artists"
        /// A ``LibrayListItem`` for compilations
        case compilations = "Compilations"
        /// A ``LibrayListItem`` for random songs
        case random = "Random songs"
        /// A ``LibrayListItem`` for never played songs
        case neverPlayed = "Never played"
        /// A ``LibrayListItem`` for  favorite songs
        case favorites = "Favorites"
        /// A ``LibrayListItem`` for the playing queue
        case queue = "Playing queue"
        /// A ``LibrayListItem`` for the search results
        case search = "Search library"
        /// A ``LibrayListItem`` for most played songs
        case mostPlayed = "Most played"
        /// A ``LibrayListItem`` for recently added songs
        case recentlyAdded = "Recently added"
        /// A ``LibrayListItem`` for recently played songs
        case recentlyPlayed = "Recently played"
        /// A ``LibrayListItem`` for playlists
        case playlist = "Playlist"
    }
}
