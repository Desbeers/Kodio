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
    /// The view
    var body: some View {
        List {
            ForEach(kodi.genres.all) { genre in
                ViewGenresListRow(genre: genre)
            }
        }
        .listStyle(SidebarListStyle())
    }
}

// MARK: - ViewGenresListRow (view)

struct ViewGenresListRow: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The genre object
    var genre: GenreFields
    /// A bit of eye-candy
    var opacity: Double {
        if kodi.albums.selected != nil {
            return 0.8
        }
        return 1
    }
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
        .padding()
        /// Make the whole listitem clickable
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            kodi.genres.selected = genre
            kodi.albums.selected = nil
            kodi.filter.albums = .genre
            kodi.filter.songs = .genre
        })
        .id(genre.genreID)
        .if(genre == kodi.genres.selected) {
            $0.background(Color.accentColor.opacity(opacity)).foregroundColor(.white)
        }
        .cornerRadius(5)
    }
}
