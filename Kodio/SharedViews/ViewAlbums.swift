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
        ScrollView {
            LazyVStack(spacing: 0) {
                ViewListHeader(title: "Albums")
                ForEach(albums) { album in
                    Button(
                        action: {
                            Library.shared.toggleAlbum(album: album)
                        }, label: {
                            row(album: album)
                        })
                        .frame(height: 88)
                        .buttonStyle(ButtonStyleList(type: .album, selected: album == selected ? true: false))
                }
            }
        }
        .id(albums)
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
            Spacer()
        }
    }
}
