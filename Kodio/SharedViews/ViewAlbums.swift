//
//  ViewAlbums.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of albums
struct ViewAlbums: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ViewListHeader(title: "Albums")
                        .id("AlbumsHeader")
                    ForEach(library.filteredContent.albums) { album in
                        Button(
                            action: {
                                library.toggleAlbum(album: album)
                            }, label: {
                                row(album: album)
                            })
                            .buttonStyle(ButtonStyleList(type: .albums, selected: album == library.selectedAlbum ? true: false))
                            .id(album.albumID)
                    }
                }
            }
            /// Scroll to the top when selecting a new smart item
            .onChange(of: library.selectedArtist) { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    proxy.scrollTo("AlbumsHeader", anchor: .center)
                }
            }
        }
    }
}

extension ViewAlbums {
    
    /// Format a genre row in a list
    /// - Parameter album: a ``Library/AlbumItem`` struct
    /// - Returns: a formatted row
    func row(album: Library.AlbumItem) -> some View {
        HStack {
            ViewArtAlbum(album: album, size: 80)
                .frame(width: 80, height: 80)
                .padding(2.5)
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Text(album.subtitle)
                    .font(.subheadline)
                Text(album.details)
                    .font(.caption)
                    .opacity(0.6)
            }
            Spacer()
        }
    }
}
