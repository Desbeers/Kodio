//
//  SongsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the songs
struct SongsView: View {
    /// The Browser model
    @Environment(BrowserModel.self) private var browser
    /// The body of the `View`
    var body: some View {
        /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    /// Scroll to the top on new selection
                    Divider()
                        .id("SongList")
                        .hidden()
                    ForEach(Array(browser.items.songs.enumerated()), id: \.element) { index, song in
                        SongView(song: song, album: browser.selection.album)
                            .id(song)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                            .padding(.trailing)
                    }
                    .task(id: browser.items.songs.map(\.id)) {
                        withAnimation(.linear(duration: 1)) {
                            proxy.scrollTo("SongList", anchor: .top)
                        }
                    }
                }
                .padding(.leading)
            }
        }
    }
}
