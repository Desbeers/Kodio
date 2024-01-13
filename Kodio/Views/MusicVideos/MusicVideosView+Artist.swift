//
//  MusicVideosView+Artist.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

extension MusicVideosView {

    /// View videos and albums for one artist
    struct Artist: View {
        /// The name of the artist
        let artist: Audio.Details.Artist
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The music videos to show
        @State private var musicVideos: [any KodiItem] = []
        /// The current `MusicVideosRouter`
        @Binding var router: Router
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
        /// The body of the `View`
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            router = .musicVideos
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
                        ForEach(musicVideos, id: \.id) { video in
                            Group {
                                switch video {
                                case let musicVideo as Video.Details.MusicVideo:
                                    KodiArt.Poster(item: video)
                                        .frame(width: 200, height: 300)
                                        .overlay(alignment: .bottom) {
                                            playButton(host: kodi.host, item: musicVideo)
                                                .padding(.vertical, 5)
                                                .frame(maxWidth: .infinity)
                                                .background(.ultraThinMaterial)
                                        }
                                case let musicVideoAlbum as Video.Details.MusicVideoAlbum:
                                    Button(action: {
                                        router = .musicVideoAlbum(musicVideoAlbum: musicVideoAlbum)
                                    }, label: {
                                        KodiArt.Poster(item: video)
                                            .frame(width: 200, height: 300)
                                    })
                                default:
                                    EmptyView()
                                }
                            }
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
                getItems()
            }
        }

        /// Get all items from the library
        private func getItems() {
            let allMusicVideosFromArtist = kodi.library.musicVideos
                .filter { $0.artist.contains(artist.artist) }
            musicVideos = allMusicVideosFromArtist
                .swapMusicVideosForAlbums(artist: artist)
                .sorted(sortItem: .init(id: "MusicVideoAlbum", method: .year, order: .ascending))
        }
    }
}
