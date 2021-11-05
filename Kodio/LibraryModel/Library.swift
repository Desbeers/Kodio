//
//  Library.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import Combine

/// Library model
class Library: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this Library class
    static let shared = Library()
    /// Combine subscription container
    var anyCancellable = Set<AnyCancellable>()
    /// The shared client class
    let kodiClient = KodiClient.shared
    /// The current library filter
    var filter: MediaType = .albumArtists
    /// The status of the library
    var status = Status() {
        didSet {
            checkStatus(status: status)
        }
    }
    /// An array containing all search related items
    var search = Search()
    /// The search query
    @Published var query = ""
    /// The library filtered by selection of smart list, genre, artist and album
    @Published var filteredContent = FilteredContent()
    /// An array containing all artist related items
    var artists = Artists()
    /// An array containing all album related items
    var albums = Albums()
    /// An array containing all song related items
    var songs = Songs()
    /// An array containing all genre related items
    var genres = Genres()
    /// An array containing all smart list related items
    var smartLists = SmartLists()
    /// An array containing all playlist related items
    var playlists = Playlists()
    /// An array with all radio stations
    var radioStations: [RadioItem] = []
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {
        /// Search observer
        search.observer.objectWillChange.sink { [self] in
            DispatchQueue.main.async {
                if search.observer.query != query {
                    query = search.observer.query
                    searchLibrary()
                }
            }
        }.store(in: &anyCancellable)
    }
}

extension Library {
 
    // MARK: - Loading library
    
    /// Get all music items from the library
    /// - Parameter reload: Bool; force a reload or else it will try to load it from the  cache
    /// - Returns: It will update the KodiClient variables
    func getLibrary(reload: Bool = false) {
        getRadioStations()
        smartLists.all = getSmartLists()
        smartLists.selected = smartLists.all.first!
        DispatchQueue.main.async {
            AppState.shared.state = .loadingLibrary
        }
        /// get media items
        Task(priority: .high) {
            /// Check if the library is still up to date
            await getLastUpdate()
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
                status.smartItems = await getSmartItems()
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
        filteredContent = Library.FilteredContent()
        playlists.files = []
        smartLists.all = []
        smartLists.selected = SmartListItem()
        radioStations = []
        Player.shared.properties = Player.Properties()
        Player.shared.item = Player.PlayerItem()
    }

    /// The loading states of the library items
    struct Status {
        /// Check if all media items are loaded
        var all: Bool {
            if artists, albums, songs, smartItems, genres, playlists {
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
        /// Loading state of the smart items
        var smartItems: Bool = false
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
        /// An ``ArtistItem``
        case artist = "Artists"
        /// An ``AlbumItem``
        case album = "Albums"
        /// A ``SongItem``
        case song = "Songs"
        /// An ``GenreItem``
        case genre = "Genres"
        /// An ``SmartListItem`` for  songs by album artists
        case albumArtists = "Album artists"
        /// A ``SmartListItem`` for compilations
        case compilations = "Compilations"
        /// A ``SmartListItem`` for random songs
        case random = "Random songs"
        /// A ``SmartListItem`` for never played songs
        case neverPlayed = "Never played"
        /// A ``SmartListItem`` for  favorite songs
        case favorites = "Favorites"
        /// A ``SmartListItem`` for the playing queue
        case queue = "Playing queue"
        /// A ``SmartListItem`` for the search results
        case search = "Search library"
        /// A ``SmartListItem`` for most played songs
        case mostPlayed = "Most played"
        /// A ``SmartListItem`` for recently added songs
        case recentlyAdded = "Recently added"
        /// A ``SmartListItem`` for recently played songs
        case recentlyPlayed = "Recently played"
        /// A ``SmartListItem`` for playlists
        case playlist = "Playlist"
    }
}

extension Library {
 
    // MARK: Sorting of media
    
    /// The sort fields for JSON requests
    struct SortFields: Encodable {
        /// The method
        var method: String = ""
        /// The order
        var order: String = ""
    }

    /// The sort methods for JSON requests
    enum SortMethod: String {
        /// Order descending
        case descending = "descending"
        /// Order ascending
        case ascending = "ascending"
        ///  Order by last played
        case lastPlayed = "lastplayed"
        ///  Order by play count
        case playCount = "playcount"
        ///  Order by year
        case year = "year"
        ///  Order by track
        case track = "track"
        ///  Order by artist
        case artist = "artist"
        ///  Order by title
        case title = "title"
        /// Nicer that using rawValue
        func string() -> String {
            return self.rawValue
        }
    }
}
