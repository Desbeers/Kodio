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
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        List {
            ForEach(kodi.artists.all) { artist in
                if artist.isAlbumArtist || !kodi.search.text.isEmpty {
                    NavigationLink(destination: ViewAlbums().onAppear {
                        print("Artist selected")
                                    //kodi.artists.selected = artist
                                    kodi.albums.selected = nil
                                    kodi.filter.albums = .artist
                                    kodi.filter.songs = .artist
                                    appState.tabs.tabSongPlaylist = .songs
                    }
                    , tag: artist
                    , selection: $kodi.artists.selected) {
                        ViewArtistsListRow(artist: artist)
                    }
                }
            }
        }
        //.listStyle(SidebarListStyle())
        .id(kodi.artistListID)
    }
}

// MARK: - ViewArtistsListRow (view)

/// The row of an artist in the list
struct ViewArtistsListRow: View {
    /// The artist object
    var artist: ArtistFields
    /// The view
    var body: some View {
        HStack {
            ViewArtArtist(artist: artist)
            Text(artist.artist)
            Spacer()
        }
        .id(artist.artist)
    }
}
