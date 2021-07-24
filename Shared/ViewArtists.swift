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
    @StateObject var artists: Artists = .shared
    /// The view
    var body: some View {
        ForEach(artists.list) { artist in
            if artist.isAlbumArtist || !KodiClient.shared.searchQuery.isEmpty {
                NavigationLink(destination: ViewDetails(), tag: artist, selection: $artists.selectedArtist) {
                    ViewArtistsListRow(artist: artist)
                }
                /// When added the id to NavigationLink, the app will crash...
                EmptyView()
                    .id(artist.artist)
            }
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
            VStack(alignment: .leading) {
                Text(artist.artist)
                Text(artist.genres.joined(separator: "・"))
                    .font(.caption)
            }
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
