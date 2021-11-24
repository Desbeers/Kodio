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
                            Task.detached(priority: .userInitiated) {
                                filtering = await Library.shared.toggleAlbum(album: album)
                            }
                        },
                        label: {
                            ViewLibraryItemListRow(item: album, size: 80)
                        })
                        .buttonStyle(ButtonStyleLibraryItem(item: album, selected: album.selected()))
                }
            }
        }
        /// Disable the view while filtering
        .disabled(filtering)
        .id(albums)
    }
}
