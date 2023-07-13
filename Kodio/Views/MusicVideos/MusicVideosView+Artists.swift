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
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The current artist
        @State var artists: [Audio.Details.Artist] = []
        /// The current `MusicVideosRouter`
        @Binding var router: Router
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
                            ForEach(artists) { artist in
                                Button(action: {
                                    router = .musicVideoArtist(artist: artist)
                                }, label: {
                                    VStack {
                                        KodiArt.Poster(item: artist)
                                            .frame(width: 200, height: 200)
                                        Text(artist.artist)
                                            .font(.headline)
                                            .padding(.bottom, 4)
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
            .task(id: kodi.library.musicVideos) {
                artists = VideoLibrary.getMusicVideoArtists()
                state = artists.isEmpty ? .empty : .ready
            }
        }
    }
}
