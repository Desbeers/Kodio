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
    /// The body of the `View`
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section(
                    content: {
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
                    }, header: {
                        PartsView.BrowserHeader(
                            label: "Albums",
                            padding: 8
                        )
                    }
                )
            }
        }
    }
}
