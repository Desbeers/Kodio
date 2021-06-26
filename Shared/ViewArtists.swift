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
    /// The list of artists
    @State var artists = [ArtistFields]()
    /// The view
    var body: some View {
        List {
            ForEach(artists) { artist in
                if artist.isAlbumArtist || !kodi.search.text.isEmpty {
                    NavigationLink(destination: ViewAlbums().onAppear {
                        kodi.albums.selected = nil
                        kodi.filter.albums = .artist
                        kodi.filter.songs = .artist
                    },
                    tag: artist,
                    selection: $kodi.artists.selected) {
                        ViewArtistsListRow(artist: artist)
                    }
                }
            }
        }
        .id(kodi.artistListID)
        .onAppear {
            artists = kodi.artistsFilter
        }
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
