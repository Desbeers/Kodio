//
//  GenresView.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Genres View
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
