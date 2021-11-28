//
//  ViewLibrary.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

#if os(macOS)
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
#endif

#if os(iOS)
/// View the whole library
struct ViewLibrary: View {
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            ViewLibraryTop()
            ViewLibraryBottom()
        }
        .toolbarButtons()
    }
}
#endif

/// View the top of the library: genres, artists and songs
struct ViewLibraryTop: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            /// A divider; else the genres, artist and albums fill scroll over the toolbar
            Divider()
            HStack(spacing: 0) {
                ViewGenres(genres: library.filteredContent.genres)
                    .frame(width: 150)
                ViewArtists(artists: library.filteredContent.artists)
                ViewAlbums(albums: library.filteredContent.albums)
            }
            .overlay(
                ViewDropShadow()
            )
        }
    }
}

/// View the bottom of the library: details and the songs
struct ViewLibraryBottom: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ViewDetails(item: library.selection, width: geometry.size == .zero ? 400 : geometry.size.width * 0.40)
                Divider()
                if library.filteredContent.songs.isEmpty {
                    ViewEmptyLibrary(item: library.selection)
                } else {
                    ViewSongs(selectedAlbum: library.albums.selected)
                }
            }
        }
        .animation(.default, value: library.selection.empty)
    }
}
