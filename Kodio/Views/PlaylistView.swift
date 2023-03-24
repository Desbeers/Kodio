//
//  PlaylistView.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The View for a playlist
struct PlaylistView: View {

    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The list of songs
    @State private var songs: [Audio.Details.Song] = []
    /// The playlist file
    let playlist: SwiftlyKodiAPI.List.Item.File
    /// The state of loading the playlist
    @State var state: AppState.State = .loading
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text(playlist.title)
                    .font(.title)
                HStack {
                    Button(action: {
                        KodioSettings.setPlayerSettings(media: .playlist)
                        songs.play()
                    }, label: {
                        Label("Play playlist", systemImage: "play.fill")
                    })
                    Button(action: {
                        KodioSettings.setPlayerSettings(media: .playlist)
                        songs.play(shuffle: true)
                    }, label: {
                        Label("Shuffle playlist", systemImage: "shuffle")
                    })
                }
                .buttonStyle(ButtonStyles.Play())
                .disabled(state != .ready)
            }
            .modifier(PartsView.ListHeader())
            switch state {
            case .loading:
                PartsView.LoadingState(message: "Getting '\(playlist.title)' songs...")
            case .empty:
                PartsView.LoadingState(message: "The playlist is empty", icon: "music.note.list")
            case .ready:
                /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
                ScrollView {
                    LazyVStack {
                        ForEach(Array(songs.enumerated()), id: \.element) { index, song in
                            SongsView.Song(song: song, album: nil)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                        }
                    }
                }
            }
        }
        .animation(.default, value: state)
        /// Get the songs from the playlist
        .task(id: kodi.library.songs) {
            let playlist = await Files.getDirectory(directory: playlist.file, media: .music).compactMap(\.id)
            songs = kodi.library.songs
                .filter { playlist.contains($0.songID) }
            state = songs.isEmpty ? .empty : .ready
        }
        .animation(.default, value: songs)
    }
}
