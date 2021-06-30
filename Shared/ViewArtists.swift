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
    @State private var artists: [ArtistFields] = []
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
        List {
            // Text(kodi.artistListID)
            ForEach(artists) { artist in
                if artist.isAlbumArtist || !kodi.search.text.isEmpty {
                    NavigationLink(destination: ViewAlbums(), tag: artist, selection: $appState.selectedArtist) {
                        ViewArtistsListRow(artist: artist)
                    }
                    /// When added the id to NavigationLink, the app will crash...
                    EmptyView()
                        .id(artist.artist)
                }
            }
        }
        .onChange(of: kodi.libraryJump) { item in
            print("Jump to \(item.artist)")
            proxy.scrollTo(item.artist, anchor: .center)
        }
        .onAppear {
            kodi.log(#function, "ViewArtists onAppear")
            artists = kodi.artistsFilter
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
    }
}

// MARK: - ViewArtistDescription (view)

struct ViewArtistDescription: View {
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The artist object
    let artist: ArtistFields?
    /// The View
    var body: some View {
        if artist != nil, !(artist?.description.isEmpty ?? true) {
            HStack {
                Spacer()
                Button("More about '\(artist!.artist)'") {
                    DispatchQueue.main.async {
                        appState.activeSheet = .viewArtistInfo
                        appState.showSheet = true
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}
