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
    
    /// The browser model
    @EnvironmentObject var browser: BrowserModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Genres")
                LazyVStack(spacing: 0) {
                    ForEach(browser.items.genres) { genre in
                        Button(action: {
                            browser.selection.genre = browser.selection.genre == genre ? nil : genre
                            browser.selection.artist = nil
                            browser.selection.album = nil
                        }, label: {
                            Text(genre.title)
                                .font(.subheadline)
                                .padding(6.5)
                        })
                        .buttonStyle(ButtonStyles.Browser(item: genre, selected: browser.selection.genre == genre))
                    }
                }
            }
        }
    }
}
