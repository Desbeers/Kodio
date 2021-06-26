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
    /// The list of artists
    @State var genres = [GenreFields]()
    /// The view
    var body: some View {
        List {
            ForEach(genres) { genre in
                NavigationLink(destination: ViewAlbums().onAppear {
                    kodi.albums.selected = nil
                    kodi.filter.albums = .genre
                    kodi.filter.songs = .genre
                }, tag: genre, selection: $kodi.genres.selected) {
                    ViewGenresListRow(genre: genre)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                genres = kodi.genres.all
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
