//
//  ViewLibrary.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the whole library
struct ViewLibrary: View {
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            SplitView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
    }
}

/// View the top of the library: genres, artists and songs
struct ViewLibraryTop: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            ViewGenres(genres: library.filteredContent.genres, selected: library.genres.selected)
                .frame(width: 150)
            ViewArtists(artists: library.filteredContent.artists, selected: library.artists.selected)
            ViewAlbums(albums: library.filteredContent.albums, selected: library.albums.selected)
        }
        .overlay(
            ViewDropShadow()
        )
    }
}

/// View the bottom of the library: details and the songs
struct ViewLibraryBottom: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            ViewDetails(item: library.selection)
            Divider()
            if library.filteredContent.songs.isEmpty {
                ViewEmptyLibrary(item: library.selection)
            } else {
                ViewSongs(songs: library.filteredContent.songs, selectedAlbum: library.albums.selected)
            }
        }
        .animation(.default, value: library.selection.empty)
    }
}
