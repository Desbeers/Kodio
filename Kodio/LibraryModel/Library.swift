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
    /// The shared search observer
    var searchObserver = SearchObserver.shared
    /// The search suggestions
    var searchSuggestions: [SearchSuggestionItem] = []
    /// The search query
    var query = "" {
        didSet {
            search()
            makeSearchSuggestions(query: query)
        }
    }
    /// The current library filter
    var media: MediaType = .albumArtists
    /// Library state
    var status = Status() {
        didSet {
            if status.all, AppState.shared.loadingState != .loaded {
                logger("Library is loaded")
                DispatchQueue.main.async {
                    AppState.shared.loadingState = .loaded
                }
            }
        }
    }
    
    @Published var filteredContent = FilteredContent()
    
    struct FilteredContent: Equatable {
        var genres: [GenreItem] = []
        var artists: [ArtistItem] = []
        var albums: [AlbumItem] = []
        var songs: [SongItem] = []
    }

    var allGenres: [GenreItem] = []
    var selectedGenre: GenreItem?
    
    var allArtists: [ArtistItem] = []
    var selectedArtist: ArtistItem?
    
    var allAlbums: [AlbumItem] = []
    var selectedAlbum: AlbumItem?
    
    var allSongs: [SongItem] = []
    var songListID = UUID().uuidString

    var randomSongs: [SongItem] = []
    var neverPlayedSongs: [SongItem] = []
    var mostPlayedSongs: [SongItem] = []
    var recentlyPlayedSongs: [SongItem] = []
    
    var allSmartLists = [SmartListItem]()
    var selectedSmartList = SmartListItem()
    
    var allPlaylists: [SmartListItem] = []
    var playlistSongs: [SongItem] = []
    
    var radioStations: [RadioItem] = []
    
    // MARK: Init
    
    private init() {
        /// Search observer
        searchObserver.objectWillChange.sink { [self] in
            DispatchQueue.main.async {
                if searchObserver.query != query {
                    query = searchObserver.query
                }
            }
        }.store(in: &anyCancellable)
    }
}

// MARK: - Get library (extension)

extension Library {
        
    /// get all music items from the library
    ///
    /// - Parameters:
    ///     - reload: Bool; force a reload or else it will try to load it from the  cache
    /// - Returns: It will update the KodiClient variables
    
    func getLibrary(reload: Bool = false) {
        getSmartLists()
        getRadioStations()
        DispatchQueue.main.async {
            AppState.shared.loadingState = .loading
        }
        /// get media items
        Task {
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
            async let playlists = getPlaylists()
            status.playlists = await playlists
            /// Songs
            if await albums {
                status.songs = await getSongs(reload: reload)
                /// Now load stuff depending on the songs
                status.smartItems = await getSmartItems()
                /// Filter the library
                filterAllMedia()
            }
        }
    }
}

// MARK: Status of library (extension)

extension Library {
    
    /// Reset library to default
    
    func reset() {
        status.reset()
        AppState.shared.loadingState = .none
        filteredContent = Library.FilteredContent()
        allPlaylists = []
        allSmartLists = []
        radioStations = []
        Player.shared.properties = Player.Properties()
        Player.shared.item = Player.PlayerItem()
    }

    /// The loading states of the library items
    
    struct Status {
        /// Check if all items are loaded
        var all: Bool {
            if artists, albums, songs, smartItems, genres, playlists {
                return true
            }
            return false
        }
        var artists: Bool = false
        var albums: Bool = false
        var songs: Bool = false
        var smartItems: Bool = false
        var playlists: Bool = false
        var genres: Bool = false
        var queue: Bool = false
        var upToDate: Bool = false
        /// Function to reset all vars to initial value
        mutating func reset() {
            self = Status()
        }
    }
}

// MARK: Media type (extension)

extension Library {
    
    /// The types of media in the library
    
    enum MediaType: String {
        case albumArtists = "Album artists"
        case artists = "Artist"
        case albums = "Album"
        case songs
        case genres
        case playlist
        case random = "Random songs"
        case neverPlayed = "Never played"
        case favorites = "Favorites"
        case queue = "Playing queue"
        case search = "Search library"
        case compilations = "Compilations"
        case mostPlayed = "Most played"
        case recentlyAdded = "Recently added"
        case recentlyPlayed = "Recently played"
    }
    
    /// Set the library filter
    
    func setFilter<T: LibraryItem>(item: T?) {
        if let selection = item?.media {
            logger("Selected '\(selection.rawValue)'")
            media = selection
        } else {
            logger("Deselected something")
            /// Find the the most fillting selection
            if let album = selectedAlbum?.media {
                media = album
            } else if let artist = selectedArtist?.media {
                media = artist
            } else if let genre = selectedGenre?.media {
                media = genre
            } else {
                media = selectedSmartList.media
            }
        }
    }
    
    /// Filter all media (genres, artists, albums and songs)
    
    func filterAllMedia() {
        Task {
            /// Filter songs first; all the rest is based on it.
            let songs = await filterSongs()
            /// Now the rest
            async let albums = filterAlbums(songList: songs)
            async let artists = filterArtists(songList: songs)
            async let genres = filterGenres(songList: songs)
            /// Update the UI
            await updateLibraryView(
                content:
                    FilteredContent(
                        genres: await genres,
                        artists: await artists,
                        albums: await albums,
                        songs: songs
                    )
            )
        }
    }
    
    func updateLibraryView(content: FilteredContent) async {
        logger("Update library UI")
        Task { @MainActor in
            filteredContent = FilteredContent(
                genres: content.genres,
                artists: content.artists,
                albums: content.albums,
                songs: content.songs)
        }
    }
}

// MARK: Sorting of media

extension Library {
    
    /// The sort fields for JSON creation
    struct SortFields: Encodable {
        /// The method
        var method: String = ""
        /// The order
        var order: String = ""
    }

    /// The available methods
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
