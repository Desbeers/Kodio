//
//  ViewGenres.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of genres
struct ViewGenres: View {
    /// The list of genres
    let genres: [Library.GenreItem]
    /// The optional selected genre
    let selected: Library.GenreItem?
    /// State of filtering the library
    @State var filtering = false
    /// The view
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ViewListHeader(title: "Genres")
                ForEach(genres) { genre in
                    Button(
                        action: {
                            Task {
                                filtering = true
                                filtering = await Library.shared.toggleGenre(genre: genre)
                            }
                        },
                        label: {
                            row(genre: genre)
                        })
                        .buttonStyle(ButtonStyleList(type: .genre, selected: genre == selected ? true: false))
                    /// Buttons have additional .traling padding for the scrollbar
                        .padding(.leading, 8)
                }
            }
        }
        /// Disable the view while filtering
        .disabled(filtering)
        .id(genres)
    }
}

extension ViewGenres {
    
    /// Format a genre row in a list
    /// - Parameter genre: a ``Library/GenreItem`` struct
    /// - Returns: a formatted row
    func row(genre: Library.GenreItem) -> some View {
        Text(genre.title)
            .font(.subheadline)
            .padding(6.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
