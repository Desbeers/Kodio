//
//  ViewArtists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View artists

/// The list of artists
struct ViewArtists: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ViewListHeader(title: "Artists")
                        .id("ArtistsHeader")
                    ForEach(library.filteredContent.artists) { artist in
                        Button(
                            action: {
                                library.toggleArtist(artist: artist)
                            },
                            label: {
                                ViewArtistsListRow(artist: artist)
                            }
                        )
                        .buttonStyle(ButtonStyleList(type: .artists, selected: artist == library.selectedArtist ? true: false))
                        /// id must be a the bottom of the 'ForEach' or else it does not work
                        .id(artist.artistID)
                    }
                }
            }
            /// Scroll to the top when selecting a new smart item
            .onChange(of: library.selectedGenre) { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    proxy.scrollTo("ArtistsHeader", anchor: .center)
                }
            }
        }
    }
}

extension ViewArtists {
    
    /// An artists in the list
    struct ViewArtistsListRow: View {
        let artist: Library.ArtistItem
        var body: some View {
            HStack {
                ViewArtArtist(artist: artist, size: 58)
                    .frame(width: 58, height: 58)
                    .padding(2)
                VStack(alignment: .leading) {
                    Text(artist.title)
                        .font(.headline)
                    Text(artist.subtitle)
                        .font(.caption)
                        .opacity(0.6)
                }
                Spacer()
            }
        }
    }
}
