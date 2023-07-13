//
//  MusicVideosView+ListItem.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

extension MusicVideosView {

    /// SwiftUI `View` for a music video in a list
    struct ListItem: View {
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        /// The music video
        let musicVideo: Video.Details.MusicVideo
        /// The body of the `View`
        var body: some View {
            HStack {
                Image(systemName: "play.fill")
                    .opacity(player.currentItem?.id == musicVideo.id ? 1 : 0)
                KodiArt.Poster(item: musicVideo)
                    .frame(width: 90, height: 160)
                VStack(alignment: .leading) {
                    Text(musicVideo.title)
                    Text(musicVideo.subtitle)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text(musicVideo.album)
                        .font(.caption)
                        .opacity(0.6)
                }
            }
        }
    }
}
