//
//  ViewAlbums.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of albums
struct ViewAlbums: View {
    /// The list of albums
    let albums: [Library.AlbumItem]
    /// The optional selected album
    let selected: Library.AlbumItem?
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ViewListHeader(title: "Albums")
                        .id("AlbumsHeader")
                    ForEach(albums) { album in
                        Button(
                            action: {
                                Library.shared.toggleAlbum(album: album)
                            }, label: {
                                row(album: album)
                            })
                            .frame(height: 88)
                            .buttonStyle(ButtonStyleList(type: .album, selected: album == selected ? true: false))
                            .id(album.albumID)
                    }
                }
                .onChange(of: albums) { _ in
                    proxy.scrollTo("AlbumsHeader", anchor: .top)
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
            ViewRemoteArt(item: album, art: .thumbnail)
                .frame(width: 80, height: 80)
                .padding(2.5)
            ViewMediaItem(item: album)
//            VStack(alignment: .leading) {
//                Text(album.title)
//                    .font(.headline)
//                Text(album.subtitle)
//                    .font(.subheadline)
//                Text(album.details)
//                    .font(.caption)
//                    .opacity(0.6)
//            }
            Spacer()
        }
    }
}
