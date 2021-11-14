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
                            row(artist: artist)
                        }
                    )
                        .buttonStyle(ButtonStyleList(type: .artist, selected: artist == selected ? true: false))
                        .frame(height: 66)
                }
            }
        }
        .id(artists)
    }
}

extension ViewArtists {
    
    /// Format an artist row in a list
    /// - Parameter artist: a ``Library/ArtistItem`` struct
    /// - Returns: a formatted row
    func row(artist: Library.ArtistItem) -> some View {
        HStack {
            ViewRemoteArt(item: artist, art: .thumbnail)
                .frame(width: 58, height: 58)
                .padding(2)
            ViewMediaItem(item: artist)
            Spacer()
        }
    }
}
