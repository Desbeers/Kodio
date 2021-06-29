///
/// ViewAlbums.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewAlbums (view)

/// The main albums view
struct ViewAlbums: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The list of albums
    @State private var albums: [AlbumFields] = []
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            /// In a VStack or else the list will not update on search (??)
            VStack {
                // Text(kodi.albumListID)
                List {
                    ViewArtFanart()
                    ForEach(albums) { album in
                        NavigationLink(destination: ViewDetails(), tag: album, selection: $appState.selectedAlbum) {
                            ViewAlbumsListRow(album: album)
                        }
                    }
                    ViewAlbumsArtistDescription(artist: appState.selectedArtist)
                }
                .id(kodi.albumListID)
                .onChange(of: kodi.libraryJump) { item in
                    proxy.scrollTo(item.albumID, anchor: .top)
                }
            }
            .onAppear {
                kodi.log(#function, "ViewAlbums onAppear")
                albums = kodi.albumsFilter
            }
            .modifier(DetailsModifier())
        }
    }
}

// MARK: - ViewAlbumsListRow (view)

/// The row of an album in the list
struct ViewAlbumsListRow: View {
    /// The album object
    let album: AlbumFields
    /// The view
    var body: some View {
        HStack {
            ViewArtAlbum(album: album)
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Group {
                    Text(album.artist.joined(separator: " & "))
                    Text(album.details.joined(separator: "・"))
                }
                .font(.caption)
            }
            Spacer()
        }
        .id(album.albumID)
    }
}

// MARK: - ViewAlbumsArtistDescription (view)

struct ViewAlbumsArtistDescription: View {
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
