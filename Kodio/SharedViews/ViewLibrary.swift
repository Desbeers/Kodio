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
                ViewGenres(
                    genres: library.filteredContent.genres,
                    listID: library.genres.listID
                )
                    .frame(width: 150)
                ViewArtists(
                    artists: library.filteredContent.artists,
                    listID: library.artists.listID
                )
                ViewAlbums(
                    albums: library.filteredContent.albums,
                    listID: library.albums.listID
                )
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
    /// Toggle for macOS table view of songs
    @AppStorage("viewSongsTable") var viewSongsTable = false
    /// The view
    var body: some View {
        if viewSongsTable {
            Group {
                if library.filteredContent.songs.isEmpty {
                    ViewEmptyLibrary(item: library.selection)
                } else {
#if os(macOS)
                    ViewSongsTable(
                        songs: library.filteredContent.songs,
                        listID: library.songs.listID
                    )
#endif
#if os(iOS)
                    /// iOS has no table view; below should never happen
                    EmptyView()
#endif
                }
            }
            .animation(.default, value: library.selection.empty)
        } else {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    if !viewSongsTable {
                        ViewDetails(
                            item: library.selection,
                            width: geometry.size == .zero ? 400 : geometry.size.width * 0.40
                        )
                        Divider()
                    }
                    if library.filteredContent.songs.isEmpty {
                        ViewEmptyLibrary(item: library.selection)
                    } else {
                        ViewSongs(
                            songs: library.filteredContent.songs,
                            listID: library.songs.listID,
                            selectedAlbum: library.albums.selected
                        )
                    }
                }
            }
            .animation(.default, value: library.selection.empty)
        }
    }
}
