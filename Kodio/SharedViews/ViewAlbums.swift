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
    /// State of filtering the library
    @State var filtering = false
    /// The view
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ViewListHeader(title: "Albums")
                ForEach(albums) { album in
                    Button(
                        action: {
                            filtering = true
                            Task {
                                filtering = await Library.shared.toggleAlbum(album: album)
                            }
                        },
                        label: {
                            ViewMediaItemListRow(item: album, size: 80)
                        })
                        .buttonStyle(ButtonStyleList(type: .album, selected: album == selected ? true: false))
                }
            }
        }
        /// Disable the view while filtering
        .disabled(filtering)
        .id(albums)
    }
}
