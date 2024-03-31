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
    /// The Browser model
    @Environment(BrowserModel.self) private var browser
    /// The body of the `View`
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section(
                    content: {
                        ForEach(browser.items.genres) { genre in
                            Button(action: {
                                withAnimation {
                                    browser.selection.genre = browser.selection.genre == genre ? nil : genre
                                    browser.selection.artist = nil
                                    browser.selection.album = nil
                                }
                            }, label: {
                                Text(genre.title)
                                    .font(.subheadline)
                                    .padding(6.5)
                            })
                            .buttonStyle(ButtonStyles.Browser(item: genre, selected: browser.selection.genre == genre))
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
