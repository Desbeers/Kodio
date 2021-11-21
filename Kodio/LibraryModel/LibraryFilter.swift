//
//  LibraryFilter.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Filter the library
    
    /// A struct with the filtered genres, artists, albums and songs
    struct FilteredContent: Equatable {
        /// Genres
        var genres: [GenreItem] = []
        /// Artists
        var artists: [ArtistItem] = []
        /// Albums
        var albums: [AlbumItem] = []
        /// Songs
        var songs: [SongItem] = []
        /// The list ID
        var listID = UUID()
    }
    
    /// Filter the genres
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of genre items
    func filterGenres(songList: [SongItem]) async -> [GenreItem] {
        logger("Filter genres")
        /// Filter genres based on song list
        let filter = songList.map { song -> [Int] in
            return song.genreID
        }
        let genreIDs: [Int] = filter.flatMap { $0 }.removingDuplicates()
        return genres.all.filter({genreIDs.contains($0.genreID)})
    }
    
    /// Filter the artists
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of artist items
    func filterArtists(songList: [SongItem]) async -> [ArtistItem] {
        logger("Filter artists")
        var artistList = artists.all
        /// Show only album artists when that is selected in the sidebar
        if libraryLists.selected.media == .albumArtists {
            artistList = artistList.filter {$0.isAlbumArtist == true}
        }
        /// Filter artists based on songs list
        let filter = songList.map { song -> [Int] in
            return song.artistID
        }
        let artists: [Int] = filter.flatMap { $0 }.removingDuplicates()
        return artistList.filter({artists.contains($0.artistID)}).sorted {$0.artist < $1.artist}
    }
    
    /// Filter the albums
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of album items
    func filterAlbums(songList: [SongItem]) async -> [AlbumItem] {
        logger("Filter albums")
        let albumList = albums.all
        /// Filter albums based on songs list
        let allAlbums = songList.map { song -> Int in
            return song.albumID
        }
        let albumIDs = allAlbums.removingDuplicates()
        return albumList
            .filter({albumIDs.contains($0.albumID)})
            .sorted { $0.artist == $1.artist ? $0.year < $1.year : $0.artist.first! < $1.artist.first! }
    }
    
    /// Filter the songs
    func filterSongs() async -> [SongItem] {
        logger("Filter songs")
        var songList = songs.all
        switch libraryLists.selected.media {
        case .search:
            songList = search.results
        case .compilations:
            songList = songList.filter {$0.compilation == true}.sorted {$0.artists < $1.artists}
        case .recentlyPlayed:
            songList = songs.recentlyPlayed
        case .recentlyAdded:
            songList = Array(songList.sorted {$0.dateAdded > $1.dateAdded}.prefix(100))
        case .mostPlayed:
            songList = songs.mostPlayed
        case .random:
            songList = songs.random
        case .neverPlayed:
            songList = songs.neverPlayed
        case .playlist:
            songList = playlists.songs
        case .favorites:
            songList = songList.filter { $0.rating > 0 }.sorted {$0.rating > $1.rating}
        case .queue:
            songList = getSongsFromQueue()
        default:
            songList = songList.filter {$0.compilation == false}
        }
        /// Filter on a genre if one is selected
        if let genre = genres.selected {
            songList = songList.filter { $0.genre.contains(genre.label)}
        }
        /// Filter on an artist if one is selected
        if let artist = artists.selected {
            songList = songList.filter {$0.artist.contains(artist.artist)}.sorted {$0.title < $1.title}
        }
        /// Filter on an album if one is selected
        if let album = albums.selected {
            /// Filter by disc and then by track
            songList = songList.filter { $0.albumID == album.albumID }
                .sorted { $0.disc == $1.disc ? $0.track < $1.track : $0.disc < $1.disc }
        }
        /// Give the list a new ID
        filteredContent.listID = UUID()
        /// Return the list of filtered songs
        return songList
    }
    
    /// Set the library filter selection
    /// - Parameter item: The selected ``LibraryItem``
    func setLibrarySelection<T: LibraryItem>(item: T?) {
        if let selected = item {
            selection = selected
        } else {
            /// Find the the most fillting selection
            if let album = albums.selected {
                selection = album
            } else if let artist = artists.selected {
                selection = artist
            } else if let genre = genres.selected {
                selection = genre
            } else {
                selection = libraryLists.selected
            }
        }
        logger("Selected \(selection.media.rawValue)")
    }
    
    /// Filter all media (genres, artists, albums and songs)
    func filterAllMedia() {
        Task {
            /// Filter the songs
            let songs = await filterSongs()
            /// Now the rest
            async let albums = filterAlbums(songList: songs)
            async let artists = filterArtists(songList: songs)
            async let genres = filterGenres(songList: songs)
            /// Update the View
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
    
    /// Update the SwiftUI View
    @MainActor func updateLibraryView(content: FilteredContent) {
        logger("Update library UI")
        filteredContent = FilteredContent(
             genres: content.genres,
             artists: content.artists,
             albums: content.albums,
             songs: content.songs)
        /// Update the selection
        if let selected = getLibraryLists().first(where: { $0.media == selection.media}) {
            selection = selected
        }
    }

    /// A pager when listng library items
    /// - Note: This needs `tasks` on SwiftUI List and List rows
    /// - Parameters:
    ///   - items: An array of ``LibraryItem`` structs
    ///   - page: The page number to show
    /// - Returns: A reduced array of ``LibraryItem`` structs
    static func pager<T: LibraryItem>(items: [T], page: Int = 0, all: Bool = false) async -> [T] {
        /// The total items we have
        let totalItems = items.count
        /// The total amount of songs per page
        let amount = 20
        /// Calculate the start range
        let pageStart = all ? 0 : page * amount
        /// Calculate the end range
        /// - Note: Reduce with 1 because the array starts at 0
        let pageEnd = (pageStart + amount < totalItems ? pageStart + amount  : totalItems) - 1
        /// Return the range of songs
        return Array(items[pageStart...pageEnd])
    }
}
