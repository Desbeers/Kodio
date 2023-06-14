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

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Genres")
                LazyVStack(spacing: 0) {
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
                }
            }
        }
    }
}
