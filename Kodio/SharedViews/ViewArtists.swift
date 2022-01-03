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
    /// The ID of the artist list
    let listID: UUID
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
                            filtering = true
                            Task.detached(priority: .userInitiated) {
                                filtering = await Library.shared.toggleArtist(artist: artist)
                            }
                        },
                        label: {
                            ViewLibraryItemListRow(item: artist, size: 58)
                        }
                    )
                        .buttonStyle(ButtonStyleLibraryItem(item: artist, selected: artist.selected()))
                }
            }
        }
        /// Disable the view while filtering
        .disabled(filtering)
        .id(listID)
        .animation(.default, value: artists)
    }
}
