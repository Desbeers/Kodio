//
//  ViewArtists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of artists
struct ViewArtists: View {
    /// The list of artists
    let artists: [Library.ArtistItem]
    /// The optional selected artist
    let selected: Library.ArtistItem?
    /// The view
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ViewListHeader(title: "Artists")
                ForEach(artists) { artist in
                    Button(
                        action: {
                            Library.shared.toggleArtist(artist: artist)
                        },
                        label: {
                            ViewMediaItemListRow(item: artist, size: 58)
                        }
                    )
                        .buttonStyle(ButtonStyleList(type: .artist, selected: artist == selected ? true: false))
                }
            }
        }
        .id(artists)
    }
}
