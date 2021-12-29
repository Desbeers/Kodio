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
        return artistList.filter({artists.contains($0.artistID)})
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
    }
    
    /// Filter the songs
    func filterSongs() async -> [SongItem] {
        logger("Filter songs")
        var songList: [SongItem] = []
        switch libraryLists.selected.media {
        case .search:
            songList = search.results
        case .compilations:
            songList = songs.all.filter {$0.compilation == true || $0.comment.contains("[compilation]")}
        case .recentlyPlayed:
            songList = Array(songs.all.sorted {$0.lastPlayed > $1.lastPlayed}.prefix(500))
        case .recentlyAdded:
            songList = Array(songs.all.sorted {$0.dateAdded > $1.dateAdded}.prefix(500))
        case .mostPlayed:
            songList = Array(songs.all.sorted {$0.playCount > $1.playCount}.prefix(500))
        case .playlist:
            async let songs = getPlaylistSongs(file: libraryLists.selected.file)
            songList = await songs
        case .favorites:
            songList = songs.all.filter { $0.rating > 0 }.sorted {$0.rating > $1.rating}
        case .queue:
            songList = getSongsFromQueue()
        default:
            songList = songs.all.filter {$0.compilation == false}
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
        /// Return the list of filtered songs
        return songList
    }
    
    /// Update the SwiftUI View
    @MainActor func updateLibraryView(content: FilteredContent) {
        logger("Update library UI")
        filteredContent = FilteredContent(
             genres: content.genres,
             artists: content.artists,
             albums: content.albums,
             songs: content.songs,
             listID: UUID()
        )
    }
    
    /// Get the songs from the database to add to the queue list
    /// - Returns: An array of song items
    func getSongsFromQueue() -> [Library.SongItem] {
        var songList: [Library.SongItem] = []
        let allSongs = songs.all
        for (index, song) in Queue.shared.queueItems.enumerated() {
            if var item = allSongs.first(where: { $0.songID == song.songID }) {
                item.queueID = index
                songList.append(item)
            }
        }
        return songList
    }

    /// A pager when listing library items
    /// - Note: This needs `tasks` on SwiftUI List and List rows
    /// - Parameters:
    ///   - items: An array of ``LibraryItem`` structs
    ///   - page: The page number to show
    ///   - all: Load all items up to the page end; this is to refresh a list instead of just extending it
    /// - Returns: A reduced array of ``LibraryItem`` structs
    static func pager<T: LibraryItem>(items: [T], page: Int = 0, all: Bool = false) async -> [T] {
        /// The total items we have
        let totalItems = items.count
        /// If an item is removed; the list can be empty
        if totalItems != 0 {
            /// The total amount of songs per page
            let amount = 20
            /// Calculate the start range
            let pageStart = all ? 0 : (page * amount)
            /// Calculate the end range
            /// - Note: Reduce with 1 because the array starts at 0
            let pageEnd = (pageStart + amount < totalItems ? pageStart + amount  : totalItems) - 1
            /// Return the range of songs
            return Array(items[pageStart...pageEnd])
        } else {
            return []
        }
    }
}
