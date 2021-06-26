///
/// ViewGenres.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewGenres (view)

/// The main genres view
struct ViewGenres: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        List {
            ForEach(kodi.genres.all) { genre in
                
                NavigationLink(destination: ViewAlbums().onAppear {
                    print("Genre selected")
                    //kodi.genres.selected = genre
                    kodi.albums.selected = nil
                    kodi.filter.albums = .genre
                    kodi.filter.songs = .genre
                                //appState.tabs.tabSongPlaylist = .songs
                }
                , tag: genre
                , selection: $kodi.genres.selected) {
                    ViewGenresListRow(genre: genre)
                }
                
                //ViewGenresListRow(genre: genre)
            }
        }
        .listStyle(SidebarListStyle())
    }
}

// MARK: - ViewGenresListRow (view)

struct ViewGenresListRow: View {
    /// The genre object
    var genre: GenreFields
    /// The view
    var body: some View {
        HStack {
            Image(systemName: "dot.radiowaves.left.and.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .cornerRadius(5)
            Text(genre.label)
            Spacer()
        }
        .id(genre.genreID)
    }
}
