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
    /// State of filtering the library
    @State var filtering = false
    /// The view
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ViewListHeader(title: "Artists")
                ForEach(artists) { artist in
                    Button(
                        action: {
                            Task {
                                filtering = true
                                filtering = await Library.shared.toggleArtist(artist: artist)
                            }
                        },
                        label: {
                            ViewMediaItemListRow(item: artist, size: 58)
                        }
                    )
                        .buttonStyle(ButtonStyleList(type: .artist, selected: artist == selected ? true: false))
                }
            }
        }
        /// Disable the view while filtering
        .disabled(filtering)
        .id(artists)
    }
}
