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
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            ViewArtFanart()
            ScrollViewReader { proxy in
                List {
                    ForEach(kodi.albumsFilter, id: \.self) { album in
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
                    /// If the artist has only one album; select it
                    if kodi.albumsFilter.count == 1 {
                        kodi.albums.selected = kodi.albumsFilter.first!
                        kodi.filter.songs = .album
                    }
                    
                }
            }
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
