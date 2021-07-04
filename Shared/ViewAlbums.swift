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
    /// The albums object
    @StateObject var albums: Albums = .shared
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            // Text(kodi.albumListID)
            List {
                ViewArtFanart()
                ForEach(albums.list) { album in
                    NavigationLink(destination: ViewDetails(), tag: album, selection: $albums.selectedAlbum) {
                        ViewAlbumsListRow(album: album)
                    }
                    /// When added the id to NavigationLink, the app will crash...
                    EmptyView()
                        .id(album.albumID)
                }
                ViewArtistDescription(artist: Artists.shared.selectedArtist)
            }
            .id(KodiClient.shared.albumListID)
            .onChange(of: KodiClient.shared.libraryJump) { item in
                proxy.scrollTo(item.albumID, anchor: .top)
            }
            .modifier(AlbumsModifier())
        }
        .onAppear {
            print("Album appear")
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
