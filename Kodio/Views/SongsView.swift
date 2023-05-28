//
//  SongsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Songs View
struct SongsView: View {
    /// The songs for this View
    let songs: [Audio.Details.Song]
    /// The optional selected album
    let selectedAlbum: Audio.Details.Album?
    /// The body of the View
    var body: some View {
        /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    /// Scroll to the top on new selection
                    Divider()
                        .id("SongList")
                        .hidden()
                    ForEach(Array(songs.enumerated()), id: \.element) { index, song in
                        SongView(song: song, album: selectedAlbum)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                            .padding(.trailing)
                    }
                    .task(id: songs) {
                        proxy.scrollTo("SongList", anchor: .top)
                    }
                }
            }
            .padding(.leading)
        }
    }
}
