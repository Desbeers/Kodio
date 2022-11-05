//
//  DetailsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Albums View
struct AlbumsView: View {
    
    /// The browser model
    @EnvironmentObject var browser: BrowserModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Albums")
                LazyVStack(spacing: 0) {
                    ForEach(browser.items.albums) { album in
                        Button(action: {
                            browser.selection.album = browser.selection.album == album ? nil : album
                        }, label: {
                            HStack {
                                KodiArt.Poster(item: album)
                                    .cornerRadius(4)
                                    .frame(width: 80, height: 80)
                                    .padding(2)
                                VStack(alignment: .leading) {
                                    Text(album.title)
                                    Text(album.displayArtist)
                                        .font(.subheadline)
                                        .opacity(0.8)
                                    Text("\(album.year.description) ∙ \(album.genre.joined(separator: "∙"))")
                                        .font(.caption)
                                        .opacity(0.6)
                                }
                            }
                        })
                        .buttonStyle(ButtonStyles.Browser(item: album, selected: browser.selection.album == album))
                    }
                }
            }
        }
        .id(browser.items.albums)
    }
}
