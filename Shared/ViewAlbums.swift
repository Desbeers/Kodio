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
    /// Show long artist description or not
    @State private var showDescription: Bool = false
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            ViewArtFanart()
            if kodi.artists.selected != nil, !(kodi.artists.selected?.description.isEmpty ?? true) {
                ViewDescription(description: kodi.artists.selected!.description)
            }
            ScrollViewReader { proxy in
                List {
                    ForEach(kodi.albumsFilter, id: \.self) { album in
                        ViewAlbumsListRow(album: album)
                    }
                }
                .id(kodi.albumListID)
                .onChange(of: kodi.libraryJump) { item in
                    proxy.scrollTo(item.albumID, anchor: .top)
                }
                .onChange(of: kodi.artists.selected) { _ in
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

// MARK: - ViewGenresListRow (view)

/// The row of an album in the list
struct ViewAlbumsListRow: View {
    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    var album: AlbumFields
    /// The view
    var body: some View {
        HStack {
            ViewArtAlbum(album: album)
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Group {
                    Text(album.artist.first!)
                    HStack(spacing: 0) {
                        Text(String(album.year))
                        Text("∙")
                        Text(album.genre.first ?? "")
                    }
                    Text(album.playCountLabel)
                    .isHidden(kodi.filter.songs != .mostPlayed)
                }
                .font(.caption)
            }
            Spacer()
        }
        .if(album == kodi.albums.selected) {
            $0.background(Color.accentColor).foregroundColor(.white)
        }
        .cornerRadius(5)
        .padding(.bottom, 6)
        /// Make the whole listitem clickable
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            kodi.albums.selected = album
            kodi.filter.songs = .album
            appState.tabs.tabSongPlaylist = .songs
        })
        .id(album.albumID)
    }
}
