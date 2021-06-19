///
/// ViewArtists.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewArtists (view)

/// The main artists view
struct ViewArtists: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        List {
            ForEach(kodi.artistsFilter) { artist in
                if (artist.isAlbumArtist || !kodi.search.text.isEmpty) {
                    ViewArtistsListRow(artist: artist)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .id(kodi.artistListID)
    }
}

// MARK: - ViewArtistsListRow (view)

/// The row of an artist in the list
struct ViewArtistsListRow: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The artist object
    var artist: ArtistFields
    /// A bit of eye-candy
    var opacity: Double {
        if kodi.albums.selected != nil {
            return 0.8
        }
        return 1
    }
    /// The view
    var body: some View {
        HStack {
            ViewArtArtist(artist: artist)
            Text(artist.artist)
            Spacer()
        }
        /// Make the whole listitem clickable
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            kodi.artists.selected = artist
            kodi.albums.selected = nil
            kodi.filter.albums = .artist
            kodi.filter.songs = .artist
            appState.tabs.tabSongPlaylist = .songs
        })
        .if(artist == kodi.artists.selected) {
            $0.background(Color.accentColor.opacity(opacity)).foregroundColor(.white)
        }
        .cornerRadius(5)
        .padding(.bottom, 6)
        .id(artist.artist)
    }
}
