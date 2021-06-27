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
    /// The list of artists
    // @State var artists = [ArtistFields]()
    /// The view
    var body: some View {
        List {
            // Text(kodi.artistListID)
            ForEach(kodi.artistsFilter) { artist in
                if artist.isAlbumArtist || !kodi.search.text.isEmpty {
                    NavigationLink(destination: ViewAlbums(), tag: artist, selection: $appState.selectedArtist) {
                        ViewArtistsListRow(artist: artist)
                    }
                }
            }
        }
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
