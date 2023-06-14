//
//  GenresView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the artists
struct ArtistsView: View {

    /// The artists for this View
    let artists: [Audio.Details.Artist]
    /// The optional selection
    @Binding var selection: BrowserModel.Selection

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Artists")
                LazyVStack(spacing: 0) {
                    ForEach(artists) { artist in
                        Button(action: {
                            selection.artist = selection.artist == artist ? nil : artist
                            selection.album = nil
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
                        .buttonStyle(ButtonStyles.Browser(item: artist, selected: selection.artist == artist))
                    }
                }
            }
        }
    }
}
