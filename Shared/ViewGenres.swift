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
//    /// The object that has it all
//    @EnvironmentObject var kodi: KodiClient
//    /// State of application
//    @EnvironmentObject var appState: AppState
//    /// The list of genres
//    @State private var genres: [GenreFields] = []
    /// The albums object
    @StateObject var genres: Genres = .shared
    /// The view
    var body: some View {
        List {
            ForEach(genres.list) { genre in
                NavigationLink(destination: ViewAlbums(), tag: genre, selection: $genres.selectedGenre) {
                    ViewGenresListRow(genre: genre)
                }
            }
        }
        .onAppear {
            print("ViewGenres onAppear")
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
