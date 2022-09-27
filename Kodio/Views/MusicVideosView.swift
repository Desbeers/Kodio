//
//  MusicVideosView.swift
//  Kodio
//
//  Created by Nick Berendsen on 18/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Music Videos View
struct MusicVideosView: View {
    @State var router: MusicVideosRouter
    var body: some View {
        VStack {
            switch router {
            case .all:
                Artists(router: $router)
            case .artist(let artist):
                Artist(artist: artist, router: $router)
            case .album(let album):
                Album(album: album, router: $router)
            }
        }
        .animation(.default, value: router)
    }
}

extension MusicVideosView {
    
    /// The router for this ``MusicVideosView``
    enum MusicVideosRouter: Hashable {
        case all
        case artist(artist: String)
        case album(album: Video.Details.MusicVideo)
    }
}

extension MusicVideosView {
    
    /// View all artists
    struct Artists: View {
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        @State var artists: [String] = []
        @Binding var router: MusicVideosRouter
        /// The state of loading the queue
        @State var state: AppState.State = .loading
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
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
                                        if let artistDetails = KodiConnector.shared.library.artists.first(where: {$0.artist == artist}) {
                                            KodiArt.Poster(item: artistDetails)
                                                .frame(width: 200, height: 200)
                                        } else {
                                            Image(systemName: "music.quarternote.3")
                                                .resizable()
                                                .padding(20)
                                                .frame(width: 200, height: 200)
                                        }
                                        Text(artist)
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
                artists = kodi.library.musicVideos.unique(by: {$0.artist.first}).flatMap({$0.artist})
                if artists.isEmpty {
                    state = .empty
                } else {
                    state = .ready
                }
            }
        }
    }
    
    /// View videos and albums for one artist
    struct Artist: View {
        let artist: String
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        @State var musicVideos: [Video.Details.MusicVideo] = []
        @Binding var router: MusicVideosRouter
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
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
                    Text(artist)
                        .font(.title)
                }
                .modifier(PartsView.ListHeader())
                ScrollView {
                    LazyVGrid(columns: grid, spacing: 0) {
                        ForEach(musicVideos) { musicVideo in
                            ZStack(alignment: .bottom) {
                                KodiArt.Poster(item: musicVideo)
                                    .frame(width: 200, height: 300)
                                    .onTapGesture {
                                        if !musicVideo.album.isEmpty {
                                            router = .album(album: musicVideo)
                                        }
                                    }
                                    .overlay(alignment: .bottom) {
                                        if musicVideo.album.isEmpty {
                                            playButtons(item: musicVideo)
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
                musicVideos = kodi.library.musicVideos
                    .filter({$0.artist.contains(artist)}).uniqueAlbum()
                    .sorted { $0.year < $1.year }
            }
        }
    }
    
    /// View videos from an album of an artist
    struct Album: View {
        let album: Video.Details.MusicVideo
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        @State var musicVideos: [Video.Details.MusicVideo] = []
        @Binding var router: MusicVideosRouter
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 320))]
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            router = .artist(artist: album.artist.first ?? "")
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
                                KodiArt.Art(file: musicVideo.art.icon)
                                    .frame(width: 320, height: 180)
                            }
                            .overlay(alignment: .bottom) {
                                MusicVideosView.playButtons(item: musicVideo)
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
                    .filter({$0.artist == album.artist && $0.album == album.album})
                    .sorted { $0.year < $1.year }
            }
        }
    }
}

extension MusicVideosView {
    
    static func playButtons(item: Video.Details.MusicVideo) -> some View {
        HStack {
            Button(action: {
                item.play()
            }, label: {
                Label("Play", systemImage: "play.fill")
            })
            StreamButton(item: item)
        }
        .buttonStyle(ButtonStyles.Play())
    }
}

extension MusicVideosView {
    
    struct StreamButton: View {
        let item: any KodiItem
        @Environment(\.openWindow) var openWindow
        /// The SceneState model
        @EnvironmentObject var scene: SceneState
        var body: some View {
            Button(action: {
#if os(macOS)
                openWindow(value: item)
#else
                scene.viewMusicVideo(item: item)
#endif
            }, label: {
                Label("Stream", systemImage: "network")
            })
        }
    }
}

extension MusicVideosView {
    
    struct PlayAlbumButton: View {
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        let item: any KodiItem
        var shuffle: Bool
        var body: some View {
            Button(action: {
                let album = kodi.library.musicVideos.filter({$0.subtitle == item.subtitle && $0.details == item.details})
                album.play(shuffle: shuffle)
                
            }, label: {
                Label("\(shuffle ? "Shuffle" : "Play") Album", systemImage: shuffle ? "shuffle" : "play.fill")
            })
            .buttonStyle(ButtonStyles.Play())
        }
    }
}

extension MusicVideosView {
    
    struct MusicVideo: View {
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        let musicVideo: Video.Details.MusicVideo
        var body: some View {
            HStack {
                Image(systemName: "play.fill")
                    .opacity(player.currentItem?.id == musicVideo.id ? 1 : 0)
                KodiArt.Art(file: musicVideo.art.icon)
                    .frame(width: 160, height: 90)
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
            .swipeActions(edge: .leading) {
                Button(action: {
                    musicVideo.play()
                }, label: {
                    Label("Play", systemImage: "play")
                    
                })
                .tint(.green)
            }
        }
    }
}
