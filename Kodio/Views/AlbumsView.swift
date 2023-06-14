//
//  DetailsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the albums
struct AlbumsView: View {

    /// The albums for this View
    let albums: [Audio.Details.Album]
    /// The optional selected album
    @Binding var selectedAlbum: Audio.Details.Album?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                PartsView.BrowserHeader(label: "Albums")
                LazyVStack(spacing: 0) {
                    ForEach(albums) { album in
                        Button(action: {
                            selectedAlbum = selectedAlbum == album ? nil : album
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
                        .buttonStyle(ButtonStyles.Browser(item: album, selected: selectedAlbum == album))
                    }
                }
            }
        }
    }
}
