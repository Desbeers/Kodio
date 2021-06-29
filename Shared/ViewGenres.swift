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
    /// The list of genres
    @State private var genres: [GenreFields] = []
    /// The view
    var body: some View {
        List {
            ForEach(genres) { genre in
                NavigationLink(destination: ViewAlbums(), tag: genre, selection: $appState.selectedGenre) {
                    ViewGenresListRow(genre: genre)
                }
            }
        }
        .onAppear {
            kodi.log(#function, "ViewGenres onAppear")
            genres = kodi.genres.all
        }
    }
}

// MARK: - ViewGenresListRow (view)

struct ViewGenresListRow: View {
    /// The genre object
    let genre: GenreFields
    /// The view
    var body: some View {
        Label(genre.label, systemImage: "dot.radiowaves.left.and.right")
            .id(genre.genreID)
    }
}
