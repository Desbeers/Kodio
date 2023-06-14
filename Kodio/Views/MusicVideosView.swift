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
    /// The current ``MusicVideosRouter``
    @State var router: MusicVideosRouter
    /// The body of the `View`
    var body: some View {
        VStack {
            switch router {
            case .all:
                Artists(router: $router)
            case .artist(let artist):
                Artist(artist: artist, router: $router)
            case let .album(artist, album):
                Album(album: album, artist: artist, router: $router)
            }
        }
        .animation(.default, value: router)
    }
}

extension MusicVideosView {

    /// The router for this ``MusicVideosView``
    enum MusicVideosRouter: Hashable {
        /// Show all artists
        case all
        /// Show a specific artist
        case artist(artist: Audio.Details.Artist)
        /// Show an album
        case album(artist: Audio.Details.Artist, album: Video.Details.MusicVideo)
    }
}

extension MusicVideosView {

    /// View all artists
    struct Artists: View {
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The current artist
        @State var artists: [Audio.Details.Artist] = []
        /// The current `MusicVideosRouter`
        @Binding var router: MusicVideosRouter
        /// The state of loading the queue
        @State var state: AppState.State = .loading
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
        /// The body of the `View`
        var body: some View {
            VStack {
                Text("Your Music Videos")
                    .font(.title)
                    .modifier(PartsView.ListHeader())

                switch state {
                case .loading:
                    PartsView.LoadingState(message: "Loading Music Videos...")
                case .empty:
                    PartsView.LoadingState(message: "there are no Music Videos in you library", icon: "music.note.tv")
                case .ready:
                    ScrollView {
                        LazyVGrid(columns: grid, spacing: 0) {
                            ForEach(artists, id: \.self) { artist in
                                Button(action: {
                                    router = .artist(artist: artist)
                                }, label: {
                                    VStack {
                                        KodiArt.Poster(item: artist)
                                            .frame(width: 200, height: 200)
                                        Text(artist.artist)
                                            .font(.headline)
                                            .padding(.bottom, 4)
                                    }
                                    .background(.thickMaterial)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .padding(.bottom)
                                })
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .buttonStyle(.plain)
            .task(id: kodi.library.musicVideos) {
                artists = VideoLibrary.getMusicVideoArtists()
                state = artists.isEmpty ? .empty : .ready
            }
        }
    }

    /// View videos and albums for one artist
    struct Artist: View {
        /// The name of the artist
        let artist: Audio.Details.Artist
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The music videos to show
        @State var musicVideos: [MediaItem] = []
        /// The current `MusicVideosRouter`
        @Binding var router: MusicVideosRouter
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
        /// The body of the `View`
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            router = .all
                        }, label: {
                            Label("Back to artists", systemImage: "chevron.backward")
                        })
                        .buttonStyle(ButtonStyles.MusicVideoNavigation())
                        Spacer()
                    }
                    Text(artist.artist)
                        .font(.title)
                }
                .modifier(PartsView.ListHeader())
                ScrollView {
                    LazyVGrid(columns: grid, spacing: 0) {
                        ForEach(musicVideos) { musicVideo in
                            ZStack(alignment: .bottom) {
                                KodiArt.Poster(item: musicVideo.item)
                                    .frame(width: 200, height: 300)
                                    .onTapGesture {
                                        if musicVideo.media != .musicVideo {
                                            router = .album(artist: artist, album: musicVideo.item)
                                        }
                                    }
                                    .overlay(alignment: .bottom) {
                                        if musicVideo.media == .musicVideo {
                                            playButton(item: musicVideo.item)
                                                .padding(.vertical, 5)
                                                .frame(maxWidth: .infinity)
                                                .background(.ultraThinMaterial)
                                        }
                                    }
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .padding(.bottom)
                            }
                        }
                    }
                    .padding()
                }
                .buttonStyle(.plain)
            }
            .task(id: kodi.library.musicVideos) {
                getItems()
            }
        }

        /// Get all items from the library
        private func getItems() {
            var result: [MediaItem] = []
            let allMusicVideosFromArtist = kodi.library.musicVideos
                .filter { $0.artist.contains(artist.artist) }
                .sorted { $0.year < $1.year }
            for video in allMusicVideosFromArtist.uniqueAlbum() {
                var item = video
                var count: Int = 1
                if !video.album.isEmpty {
                    let albumMusicVideos = allMusicVideosFromArtist
                        .filter { $0.album == video.album }
                    count = albumMusicVideos.count
                    /// Set the watched state for an album
                    if count != 1, !albumMusicVideos.filter({ $0.playcount == 0 }).isEmpty {
                        item.playcount = 0
                        item.resume.position = 0
                    }
                }
                result.append(
                    MediaItem(
                        id: count == 1 ? video.title : video.album,
                        media: count == 1 ? .musicVideo : .album,
                        item: item
                    )
                )
            }
            musicVideos = result
        }
    }

    /// View videos from an album of an artist
    struct Album: View {
        /// The album
        let album: Video.Details.MusicVideo
        /// The artist
        let artist: Audio.Details.Artist
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The music videos to show
        @State var musicVideos: [Video.Details.MusicVideo] = []
        /// The current `MusicVideosRouter`
        @Binding var router: MusicVideosRouter
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 320))]
        /// The body of the `View`
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            router = .artist(artist: artist)
                        }, label: {
                            Label("Back to \(album.artist.first ?? "")", systemImage: "chevron.backward")
                        })
                        .buttonStyle(ButtonStyles.MusicVideoNavigation())
                        Spacer()
                    }
                    VStack {
                        Text(album.album)
                            .font(.title)
                        HStack {
                            PlayAlbumButton(item: album, shuffle: true)
                            PlayAlbumButton(item: album, shuffle: false)
                        }
                        .buttonStyle(ButtonStyles.Play())
                    }
                }
                .modifier(PartsView.ListHeader())
                ScrollView {
                    LazyVGrid(columns: grid, spacing: 0) {
                        ForEach(musicVideos) { musicVideo in
                            VStack(spacing: 0) {
                                Text(musicVideo.title)
                                    .font(.headline)
                                    .padding(.vertical, 5)
                                KodiArt.Fanart(item: musicVideo)
                                    .frame(width: 320, height: 180)
                            }
                            .overlay(alignment: .bottom) {
                                MusicVideosView.playButton(item: musicVideo)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity)
                                    .background(.ultraThinMaterial)
                            }
                            .background(.thickMaterial)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.bottom)
                        }
                    }
                    .padding()
                }
                .buttonStyle(.plain)
            }
            .task(id: kodi.library.musicVideos) {
                musicVideos = kodi.library.musicVideos
                    .filter { $0.artist == album.artist && $0.album == album.album }
                    .sorted { $0.year < $1.year }
            }
        }
    }
}

extension MusicVideosView {

    /// Play SwiftUI button
    /// - Parameter item: The `KodiItem`
    /// - Returns: SwiftUI button
    static func playButton(item: Video.Details.MusicVideo) -> some View {
        Button(action: {
            item.play()
        }, label: {
            Label("Play", systemImage: "play.fill")
        })
        .buttonStyle(ButtonStyles.Play())
    }
}

extension MusicVideosView {

    /// SwiftUI button to play an album
    struct PlayAlbumButton: View {
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The `KodiItem`
        let item: any KodiItem
        /// Bool to shuffle or not
        var shuffle: Bool
        /// The body of the `View`
        var body: some View {
            Button(action: {
                let album = kodi.library.musicVideos
                    .filter { $0.subtitle == item.subtitle && $0.details == item.details }
                album.play(shuffle: shuffle)
            }, label: {
                Label("\(shuffle ? "Shuffle" : "Play") Album", systemImage: shuffle ? "shuffle" : "play.fill")
            })
            .buttonStyle(ButtonStyles.Play())
        }
    }
}

extension MusicVideosView {

    /// SwiftUI `View` for a music video
    struct MusicVideo: View {
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

extension MusicVideosView {

    /// An item in the Artist list, either a Video or an Album
    struct MediaItem: Identifiable {
        /// The ID of the item
        var id: String
        /// The kind of media
        var media: Library.Media = .musicVideo
        /// When playing this item, resume or not
        var resume: Bool = false
        /// The Music Video item
        var item: Video.Details.MusicVideo
    }
}
