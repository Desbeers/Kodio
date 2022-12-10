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
                        KodioSettings.setPlayerSettings(setting: .track)
                        songs.play()
                    }, label: {
                        Label("Play playlist", systemImage: "play.fill")
                    })
                    Button(action: {
                        KodioSettings.setPlayerSettings(setting: .track)
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
                List {
                    ForEach(songs) { song in
                        SongsView.Song(song: song, album: nil)
                    }
                }
#if os(macOS)
                .listStyle(.inset(alternatesRowBackgrounds: true))
#else
                .listStyle(.plain)
#endif
            }
        }
        .animation(.default, value: state)
        /// Get the songs from the playlist
        .task(id: kodi.library.songs) {
            var songList = [Audio.Details.Song]()
            let items = await Files.getDirectory(directory: playlist.file, media: .music)
            for item in items {
                if let songID = item.id, let song = kodi.library.songs.first(where: {$0.songID == songID}) {
                    songList.append(song)
                }
            }
            songs = songList
            state = songList.isEmpty ? .empty : .ready
        }
        .animation(.default, value: songs)
    }
}
