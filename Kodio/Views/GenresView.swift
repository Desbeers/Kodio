//
//  GenresView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the genres
struct GenresView: View {
    /// The genres for this View
    let genres: [Library.Details.Genre]
    /// The optional selection
    @Binding var selection: BrowserModel.Selection
    /// The body of the `View`
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section(
                    content: {
                        ForEach(genres) { genre in
                            Button(action: {
                                selection.genre = selection.genre == genre ? nil : genre
                                selection.artist = nil
                                selection.album = nil
                            }, label: {
                                Text(genre.title)
                                    .font(.subheadline)
                                    .padding(6.5)
                            })
                            .buttonStyle(ButtonStyles.Browser(item: genre, selected: selection.genre == genre))
                        }
                    }, header: {
                        PartsView.BrowserHeader(
                            label: "Genres",
                            padding: 8
                        )
                    }
                )
            }
        }
    }
}
