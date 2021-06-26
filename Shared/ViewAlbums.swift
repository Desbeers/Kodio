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
    @State var albums = [AlbumFields]()
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ViewArtFanart()
                ForEach(albums) { album in
                    NavigationLink(destination: ViewDetails().onAppear {
                        kodi.albums.selected = album
                        kodi.filter.songs = .album
                    }, tag: album, selection: $kodi.albums.selected) {
                        ViewAlbumsListRow(album: album)
                    }
                }
                if kodi.artists.selected != nil, !(kodi.artists.selected?.description.isEmpty ?? true) {
                    HStack {
                        Spacer()
                        Button("More about '\(kodi.artists.selected!.artist)'") {
                            DispatchQueue.main.async {
                                appState.activeSheet = .viewArtistInfo
                                appState.showSheet = true
                            }
                        }
                    }
                }
            }
            .id(kodi.albumListID)
            .onChange(of: kodi.libraryJump) { item in
                proxy.scrollTo(item.albumID, anchor: .top)
            }
            .onAppear {
                DispatchQueue.main.async {
                    albums = kodi.albumsFilter
                    /// If the artist has only one album; select it. Only on macOS, iOS does not like this
                    if albums.count == 1, kodi.userInterface == .macOS {
                        kodi.albums.selected = albums.first!
                        kodi.filter.songs = .album
                    }
                }
            }
            .modifier(DetailsModifier())
        }
    }
}

// MARK: - ViewAlbumsListRow (view)

/// The row of an album in the list
struct ViewAlbumsListRow: View {
    var album: AlbumFields
    /// The view
    var body: some View {
        HStack {
            ViewArtAlbum(album: album)
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Group {
                    Text(album.artist.joined(separator: " & "))
                    /// Hide details when there is no year
                    if album.year != 0 {
                        HStack(spacing: 0) {
                            Text(String(album.year))
                            Text("∙")
                            Text(album.genre.first ?? "")
                        }
                    }
                }
                .font(.caption)
            }
            Spacer()
        }
        .id(album.albumID)
    }
}
