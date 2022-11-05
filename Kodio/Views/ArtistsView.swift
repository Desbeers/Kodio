//
//  GenresView.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Artists View
struct ArtistsView: View {
    /// The browser model
    @EnvironmentObject var browser: BrowserModel
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Artists")
                LazyVStack(spacing: 0) {
                    ForEach(browser.items.artists) { artist in
                        Button(action: {
                            browser.selection.artist = browser.selection.artist == artist ? nil : artist
                            browser.selection.album = nil
                        }, label: {
                            HStack {
                                KodiArt.Poster(item: artist)
                                    .cornerRadius(4)
                                    .frame(width: 58, height: 58)
                                    .padding(2)
                                VStack(alignment: .leading) {
                                    Text(artist.title)
                                    Text(artist.subtitle)
                                        .lineLimit(1)
                                        .font(.subheadline)
                                        .opacity(0.8)
                                }
                            }
                        })
                        .buttonStyle(ButtonStyles.Browser(item: artist, selected: browser.selection.artist == artist))
                    }
                }
            }
        }
        .id(browser.items.artists)
    }
}
