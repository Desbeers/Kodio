//
//  LibraryLoad.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension Library {
 
    // MARK: Loading library
    
    /// Get all music items from the library
    /// - Parameter reload: Bool; force a reload or else it will try to load it from the  cache
    func getLibrary(reload: Bool = false) {
        let appState: AppState = .shared
        if reload {
            resetLibrary(host: appState.selectedHost)
        }
        /// get media items
        Task(priority: .high) {
            /// Set loading state
            await appState.setState(current: .loadingLibrary)
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
                /// Check if the library is still up to date
                if !reload {
                    await getLastUpdate()
                }
            }
        }
    }
    
    /// Check the loading status
    func checkStatus() {
        if status.all {
            logger("Library is loaded")
            Task {
                await AppState.shared.setState(current: .loadedLibrary)
            }
        }
    }
    
    /// Reset the  library to its initial state and set the host information
    /// - Parameter host: The currently selected host
    func resetLibrary(host: HostItem) {
        /// Set the selection with the new host information
        var listItem = LibraryListItem()
        listItem.subtitle = "Loading your library on \(host.description)"
        listItem.empty = "Loading your library"
        listItem.icon = host.icon
        selection = listItem
        /// Reset everything
        status.reset()
        genres = Genres()
        artists = Artists()
        albums = Albums()
        songs = Songs()
        filteredContent = FilteredContent()
        playlists.files = []
        libraryLists.all = []
        libraryLists.selected = LibraryListItem()
        Player.shared.properties = Player.Properties()
        Player.shared.item = Player.PlayerItem()
    }

    /// The loading states of the library items
    struct Status {
        /// Check if all media items are loaded
        var all: Bool {
            if artists, albums, songs, genres, playlists {
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
        /// Loading state of the playlists
        var playlists: Bool = false
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
        /// An ``LibraryListItem`` for  songs by album artists
        case albumArtists = "Album artists"
        /// A ``LibraryListItem`` for compilations
        case compilations = "Compilations"
        /// A ``LibraryListItem`` for  favorite songs
        case favorites = "Favorites"
        /// A ``LibraryListItem`` for the playing queue
        case queue = "Playing queue"
        /// A ``LibraryListItem`` for the search results
        case search = "Search library"
        /// A ``LibraryListItem`` for most played songs
        case mostPlayed = "Most played"
        /// A ``LibraryListItem`` for recently added songs
        case recentlyAdded = "Recently added"
        /// A ``LibraryListItem`` for recently played songs
        case recentlyPlayed = "Recently played"
        /// A ``LibraryListItem`` for playlists
        case playlist = "Playlist"
    }
}
