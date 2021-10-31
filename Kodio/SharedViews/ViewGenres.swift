//
//  ViewGenres.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of genres
struct ViewGenres: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ViewListHeader(title: "Genres")
                    ForEach(library.filteredContent.genres) { genre in
                        Button(
                            action: {
                                library.toggleGenre(genre: genre)
                            }, label: {
                                row(genre: genre)
                            })
                            .buttonStyle(ButtonStyleList(type: .genre, selected: genre == library.genres.selected ? true: false))
                    }
                }
                /// Buttons have additional .traling padding for the scrollbar
                .padding(.leading, 8)
            }
    }
}

extension ViewGenres {
    
    /// Format a genre row in a list
    /// - Parameter genre: a ``Library/GenreItem`` struct
    /// - Returns: a formatted row
    func row(genre: Library.GenreItem) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(genre.title)
                    .font(.subheadline)
                    .padding(6.5)
            }
            Spacer()
        }
    }
}
