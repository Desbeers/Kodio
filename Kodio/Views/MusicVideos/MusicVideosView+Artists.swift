//
//  MusicVideosView+Artists.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

extension MusicVideosView {

    /// View all artists
    struct Artists: View {
        /// The AppState model
        @Environment(AppState.self) private var appState
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The current artist
        @State private var artists: [Audio.Details.Artist] = []
        /// The current `MusicVideosRouter`
        @Binding var router: Router
        /// The status of loading the queue
        @State private var status: ViewStatus = .loading
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 220))]
        /// The body of the `View`
        var body: some View {
            VStack(spacing: 0) {
                Text("Your Music Videos")
                    .font(.title)
                    .modifier(PartsView.ListHeader())
                switch status {
                case .loading:
                    status.message(router: appState.selection)
                case .empty:
                    status.message(router: appState.selection)
                default:
                    ScrollView {
                        LazyVGrid(columns: grid, spacing: 0) {
                            ForEach(artists) { artist in
                                Button(action: {
                                    router = .musicVideoArtist(artist: artist)
                                }, label: {
                                    KodiArt.Poster(item: artist)
                                        .frame(width: 200, height: 200)
                                        .overlay(alignment: .bottom) {
                                            Text(artist.artist)
                                                .padding(.vertical, 5)
                                                .frame(maxWidth: .infinity)
                                                .background(.thinMaterial)
                                        }
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
            .animation(.default, value: status)
            .task(id: kodi.library.musicVideos) {
                artists = VideoLibrary.getMusicVideoArtists()
                status = artists.isEmpty ? .empty : .ready
            }
        }
    }
}
