//
//  ViewLibrary.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the whole library
struct ViewLibrary: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
            VStack(spacing: 0) {
                /// A divider; else the artist and albums fill scroll over the toolbar
                Divider()
                HStack(spacing: 0) {
                    ViewGenres(genres: library.filteredContent.genres, selected: library.genres.selected)
                        .frame(width: 200)
                    ViewArtists(artists: library.filteredContent.artists, selected: library.artists.selected)
                    ViewAlbums(albums: library.filteredContent.albums, selected: library.albums.selected)
                }
                .background(Color.accentColor.opacity(0.05))
                .overlay(
                    ViewDropShadow()
                )
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
            .toolbar()
    }
}
