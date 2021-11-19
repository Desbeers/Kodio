//
//  ViewLibrary.swift
//  Kodio (macOS)
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
        .toolbar()
    }
}
#endif

/// View the top of the library: genres, artists and songs
struct ViewLibraryTop: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The libraray class
    private let library: Library = .shared
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            /// A divider; else the genres, artist and albums fill scroll over the toolbar
            Divider()
            HStack(spacing: 0) {
                ViewGenres(genres: appState.filteredContent.genres, selected: library.genres.selected)
                    .frame(width: 150)
                ViewArtists(artists: appState.filteredContent.artists, selected: library.artists.selected)
                ViewAlbums(albums: appState.filteredContent.albums, selected: library.albums.selected)
            }
            .overlay(
                ViewDropShadow()
            )
        }
    }
}

/// View the bottom of the library: details and the songs
struct ViewLibraryBottom: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The libraray class
    private let library: Library = .shared
    /// The view
    var body: some View {
        GeometryReader { geometry in
        HStack(spacing: 0) {
            ViewDetails(item: library.selection, width: geometry.size.width * 0.40)
            Divider()
            if appState.filteredContent.songs.isEmpty {
                ViewEmptyLibrary(item: library.selection)
            } else {
                ViewSongs(songs: appState.filteredContent.songs, selectedAlbum: library.albums.selected)
            }
        }
        }
        .animation(.default, value: library.selection.empty)
    }
}
