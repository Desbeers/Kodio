//
//  LibraryFilter.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Filter content
    
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
    
    /// Set the library selection
    /// - Parameter item: The selected ``LibraryItem``
    func setLibrarySelection<T: LibraryItem>(item: T?) {
        if let selected = item {
            logger("Selected '\(selection.media.rawValue)'")
            selection = selected
        } else {
            logger("Deselected something")
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
    }
    
    /// Filter all media (genres, artists, albums and songs)
    func filterAllMedia() {
        Task {
            /// Filter songs first; all the rest is based on it
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
    /// - Parameter content: An array of filtered content
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
