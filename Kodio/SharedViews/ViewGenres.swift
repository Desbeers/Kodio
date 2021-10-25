//
//  ViewGenres.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View genres

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
                                ViewGenresListRow(genre: genre)
                            })
                            .buttonStyle(ButtonStyleList(type: .genres, selected: genre == library.selectedGenre ? true: false))
                    }
                }
                /// Buttons have additional .traling padding for the scrollbar
                .padding(.leading, 8)
            }
    }
}

extension ViewGenres {
    
    /// A genre row in the list
    struct ViewGenresListRow: View {
        /// The genre item
        let genre: Library.GenreItem
        /// The view
        var body: some View {
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
}
