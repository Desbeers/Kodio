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
        var allArtists = artists.all
        var artistList = [ArtistItem]()
        /// Show only album artists when that is selected in the sidebar
        if libraryLists.selected.media == .albumArtists || libraryLists.selected.media == .compilations {
            allArtists = allArtists.filter {$0.isAlbumArtist == true}
        }
        /// Filter artists based on songs list
        let filter = songList.map { song -> [Int] in
            return song.artistID
        }
        let artistIDs: [Int] = filter.flatMap { $0 }.removingDuplicates()
        for artistID in artistIDs {
            if let match = allArtists.first(where: { $0.artistID == artistID }) {
                artistList.append(match)
            }
        }
        /// Filter on a genre if one is selected
        if let genre = genres.selected {
            artistList = artistList.filter { $0.genres.contains(genre.label)}
        }
        return artistList
    }
    
    /// Filter the albums
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of ``AlbumItem``s
    func filterAlbums(songList: [SongItem]) async -> [AlbumItem] {
        logger("Filter albums")
        var albumList = [AlbumItem]()
        /// Filter albums based on songs list
        let allAlbums = songList.map { song -> Int in
            return song.albumID
        }
        let albumIDs = allAlbums.removingDuplicates()
        for albumID in albumIDs {
            if let match = albums.all.first(where: { $0.albumID == albumID }) {
                albumList.append(match)
            }
        }
        if libraryLists.selected.media == .compilations {
            albumList = albumList.sorted {
                $0.artistSort < $1.artistSort
            }
        }
        /// Filter on a genre if one is selected
        if let genre = genres.selected {
            albumList = albumList.filter { $0.genre.contains(genre.label)}
        }
        /// Filter on an artist if one is selected
        if let artist = artists.selected {
            albumList = albumList.filter {$0.songArtistID!.contains(artist.artistID)}
        }
        return albumList
    }
    
    func filterSelection() async -> [SongItem] {
        logger("Filter selected song list")
        /// Start with a fresh list
        var songList: [SongItem] = []
        /// # First; filter on sidebar selection
        /// - Note: Limited lists must be in an `Array`` because 'prefix' does not
        ///         return an ``Array`` but an ``ArraySlice``
        switch libraryLists.selected.media {
        case .search:
            songList = search.results
        case .compilations:
            songList = songs.all
                .filter {
                    $0.compilation == true || $0.comment.contains("[compilation]")
                }
        case .recentlyPlayed:
            songList = Array(
                songs.all
                    .filter {
                        $0.playCount > 0
                    }
                    .sorted {
                        $0.lastPlayed > $1.lastPlayed
                    }
                    .prefix(500)
            )
        case .recentlyAdded:
            songList = Array(
                songs.all
                    .sorted {
                        $0.dateAdded > $1.dateAdded
                    }
                    .prefix(500)
            )
        case .mostPlayed:
            songList = Array(
                songs.all
                    .filter {
                        $0.playCount > 0
                    }
                    .sorted {
                        $0.playCount > $1.playCount
                        
                    }
                    .prefix(500))
        case .playlist:
            /// Playlist songs are dynamic loaded; they might be 'smart'
            async let songs = getPlaylistSongs(file: libraryLists.selected.file)
            songList = await songs
        case .favorites:
            songList = songs.all
                .filter {
                    $0.rating > 0
                }
                .sorted {
                    $0.rating > $1.rating
                }
        case .queue:
            songList = Player.shared.queueSongs
        default:
            songList = songs.all
                .filter {
                    $0.compilation == false
                }
        }
        return songList
    }

    /// Filter the songs based on current selection in the UI
    /// - Returns: An array of filtered ``SongItem``s
    func filterSongs() async -> [SongItem] {
        logger("Filter songs")
        /// Start with a fresh list with all the optional songs
        var songList: [SongItem] = songs.selection
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
    
    /// Update the SwiftUI View with the filtered content
    /// - Parameter content: The filtered content
    /// - Note: Reason to do it like this is that the View only have to update once with all new items
    @MainActor func updateLibraryView(content: FilteredContent) {
        logger("Update library UI")
        filteredContent = FilteredContent(
             genres: content.genres,
             artists: content.artists,
             albums: content.albums,
             songs: content.songs
        )
    }
    
    /// Get the songs from the database to add to the queue list
    /// - Returns: An array of ``SongItem``s in the queue
    /// - Note: We can't ask Kodi directly for all the songs because our songs have a bit more information added during the first load
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
}
