//
//  Library.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI
import Combine

// MARK: - LibraryItem (protocol)

/// An item in the library: artist, album, song, playlist etc.

protocol LibraryItem: Codable, Identifiable, Hashable {
    var media: Library.MediaType { get }
    var title: String { get }
    var subtitle: String { get }
    var description: String { get }
    var icon: String { get }
    var thumbnail: String { get }
    var fanart: String { get }
    
}

// MARK: - Library model (class)

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
    @Published var scroll = Scroll()
    
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
    var favoriteSongs: [SongItem] = []
    
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
        var playerProperties: Bool = false
        var playerItem: Bool = false
        var queue: Bool = false
        var upToDate: Bool = false
        /// Function to reset all vars to initial value
        mutating func reset() {
            self = Status()
        }
    }
}

// MARK: Scroll library lists (extension)

extension Library {
    
    /// The scroll variables (artist, album and song)
    
    struct Scroll: Equatable {
        var artist: Int = 0
        var album: Int = 0
        var song: Int = 0
    }
    
    /// The function to scroll in the library lists
    
    func scrollInLibrary(song: SongItem) {
        /// Set the scroll values
        var scrollValues = Library.Scroll()
        scrollValues.song = song.songID
        /// Select the correct smart list
        selectedSmartList = !song.compilation ? allSmartLists[0] : allSmartLists[1]
        smartReload()
        /// Select the artist if the song is not part of a compilation; else all 'various artists' will be shown
        if !song.compilation,
           let artist = allArtists.first(where: { $0.artistID == song.albumArtistID.first }) {
            toggleArtist(artist: artist, force: true)
            scrollValues.artist = artist.artistID
        }
        /// Select the album
        if let album = allAlbums.first(where: { $0.albumID == song.albumID }) {
            toggleAlbum(album: album, force: true)
            scrollValues.album = album.albumID
        }
        /// Scroll to the correct library items
        DispatchQueue.main.async {
            self.scroll = scrollValues
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
                filter:
                    FilteredContent(
                        genres: await genres,
                        artists: await artists,
                        albums: await albums,
                        songs: songs
                    )
            )
        }
    }
    
    func updateLibraryView(filter: FilteredContent) async {
        logger("Update library UI")
        Task { @MainActor in
            filteredContent = FilteredContent(
                genres: filter.genres,
                artists: filter.artists,
                albums: filter.albums,
                songs: filter.songs)
        }
    }
}
