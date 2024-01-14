//
//  MusicVideosView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the music videos
struct MusicVideosView: View {
    /// The current  Router for Music Videos
    @State private var router: Router = .musicVideos

    /// The body of the `View`
    var body: some View {
        VStack {
            switch router {
            case .musicVideos:
                Artists(router: $router)
            case .musicVideoArtist(let artist):
                Artist(artist: artist, router: $router)
            case .musicVideoAlbum(let musicVideoAlbum):
                Album(album: musicVideoAlbum, router: $router)
            default:
                EmptyView()
            }
        }
        .animation(.default, value: router)
    }
}

extension MusicVideosView {

    /// Play SwiftUI button
    /// - Parameter item: The `KodiItem`
    /// - Returns: SwiftUI button
    static func playButton(host: HostItem, item: Video.Details.MusicVideo) -> some View {
        Button(action: {
            item.play(host: host)
        }, label: {
            Label("Play", systemImage: "play.fill")
        })
        .playButtonStyle()
    }
}

extension MusicVideosView {

    /// SwiftUI button to play an album
    struct PlayAlbumButton: View {
        /// The KodiConnector model
        @Environment(KodiConnector.self)
        private var kodi
        /// The `KodiItem`
        let item: any KodiItem
        /// Bool to shuffle or not
        var shuffle: Bool
        /// The body of the `View`
        var body: some View {
            Button(action: {
                let album = kodi.library.musicVideos
                    .filter { $0.subtitle == item.subtitle && $0.details == item.details }
                album.play(host: kodi.host, shuffle: shuffle)
            }, label: {
                Label("\(shuffle ? "Shuffle" : "Play") Album", systemImage: shuffle ? "shuffle" : "play.fill")
            })
            .playButtonStyle()
        }
    }
}
