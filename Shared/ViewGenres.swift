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
    /// The list of artists
    // @State var genres = [GenreFields]()
    /// The view
    var body: some View {
        List {
            ForEach(kodi.genres.all) { genre in
                NavigationLink(destination: ViewAlbums().onAppear {
                    appState.selectedAlbum = nil
                    appState.filter.albums = .genre
                    appState.filter.songs = .genre
                }, tag: genre, selection: $appState.selectedGenre) {
                    ViewGenresListRow(genre: genre)
                }
            }
        }
    }
}

// MARK: - ViewGenresListRow (view)

struct ViewGenresListRow: View {
    /// The genre object
    var genre: GenreFields
    /// The view
    var body: some View {
        Label(genre.label, systemImage: "dot.radiowaves.left.and.right")
            .id(genre.genreID)
    }
}
