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
            // Text(kodi.albumListID)
            List {
                ViewArtFanart()
                ForEach(albums) { album in
                    NavigationLink(destination: ViewDetails(), tag: album, selection: $appState.selectedAlbum) {
                        ViewAlbumsListRow(album: album)
                    }
                    /// When added the id to NavigationLink, the app will crash...
                    EmptyView()
                        .id(album.albumID)
                }
                ViewArtistDescription(artist: appState.selectedArtist)
            }
            .id(kodi.albumListID)
            .onChange(of: kodi.libraryJump) { item in
                proxy.scrollTo(item.albumID, anchor: .top)
            }
            .onAppear {
                kodi.log(#function, "ViewAlbums onAppear")
                albums = kodi.albumsFilter
            }
            .onChange(of: kodi.searchQuery) { _ in
                albums = kodi.albumsFilter.filterAlbums()
            }
            .modifier(AlbumsModifier())
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
                Text(album.artist.joined(separator: " & "))
                    .font(.subheadline)
                Text(album.details.joined(separator: "・"))
                    .font(.caption)
            }
            Spacer()
        }
    }
}

// MARK: - ViewAlbumDescription (view)

/// Optional description of an album
struct ViewAlbumDescription: View {
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The artist object
    let album: AlbumFields?
    /// The View
    var body: some View {
        if album != nil, !(album?.description.isEmpty ?? true) {
            Spacer()
            Button("Info") {
                DispatchQueue.main.async {
                    appState.activeSheet = .viewAlbumInfo
                    appState.showSheet = true
                }
            }
            .foregroundColor(.accentColor)
        } else {
            EmptyView()
        }
    }
}
