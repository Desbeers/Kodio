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
        ScrollViewReader { proxy in
        List {
            // Text(kodi.artistListID)
            ForEach(kodi.artistsFilter, id: \.id) { artist in
                if artist.isAlbumArtist || !kodi.search.text.isEmpty {
                    NavigationLink(destination: ViewAlbums(), tag: artist, selection: $appState.selectedArtist) {
                        ViewArtistsListRow(artist: artist)
                    }
                }
            }
        }
        .onChange(of: kodi.libraryJump) { item in
            print("Jump to \(item.artist)")
            proxy.scrollTo(item.artist, anchor: .center)
        }
        .id(kodi.artistListID)
        }
    }
}

// MARK: - ViewArtistsListRow (view)

/// The row of an artist in the list
struct ViewArtistsListRow: View {
    /// The artist object
    let artist: ArtistFields
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
