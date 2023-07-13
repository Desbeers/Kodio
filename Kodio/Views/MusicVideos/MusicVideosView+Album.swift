//
//  MusicVideosView+Album.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

extension MusicVideosView {

    /// View videos from an album of an artist
    struct Album: View {
        /// The album
        let album: Video.Details.MusicVideoAlbum
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The current `MusicVideosRouter`
        @Binding var router: Router
        /// Define the grid layout
        private let grid = [GridItem(.adaptive(minimum: 320))]
        /// The body of the `View`
        var body: some View {
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    HStack {
                        Button(action: {
                            router = .musicVideoArtist(artist: album.artist)
                        }, label: {
                            Label("Back to \(album.artist.artist)", systemImage: "chevron.backward")
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
                        ForEach(album.musicVideos) { musicVideo in
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
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.bottom)
                        }
                    }
                    .padding()
                }
                .buttonStyle(.plain)
            }
        }
    }
}
