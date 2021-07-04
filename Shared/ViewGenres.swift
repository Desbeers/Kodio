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
    /// The albums object
    @StateObject var genres: Genres = .shared
    /// The view
    var body: some View {
        ForEach(genres.list) { genre in
            NavigationLink(destination: ViewDetails(), tag: genre, selection: $genres.selectedGenre) {
                ViewGenresListRow(genre: genre)
            }
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
