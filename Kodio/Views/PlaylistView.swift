//
//  PlaylistView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for a playlist
struct PlaylistView: View {
    /// The AppState model
    @Environment(AppState.self) private var appState
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The list of songs
    @State private var songs: [Audio.Details.Song] = []
    /// The playlist file
    let playlist: SwiftlyKodiAPI.List.Item.File
    /// The status of loading the playlist
    @State private var status: ViewStatus = .loading
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text(playlist.title)
                    .font(.title)
                HStack {
                    Button(action: {
                        KodioSettings.setPlayerSettings(media: .playlist)
                        songs.play(host: kodi.host)
                    }, label: {
                        Label("Play playlist", systemImage: "play.fill")
                    })
                    Button(action: {
                        KodioSettings.setPlayerSettings(media: .playlist)
                        songs.play(host: kodi.host, shuffle: true)
                    }, label: {
                        Label("Shuffle playlist", systemImage: "shuffle")
                    })
                }
                .playButtonStyle()
                .disabled(status != .ready)
            }
            .modifier(PartsView.ListHeader())
            switch status {
            case .ready:
                /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
                ScrollView {
                    LazyVStack {
                        ForEach(Array(songs.enumerated()), id: \.element) { index, song in
                            SongView(song: song, album: nil)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                        }
                    }
                }
            default:
                status.message(router: appState.selection, progress: true)
            }
        }
        /// Get the songs from the playlist
        .task(id: kodi.library.songs) {
            let playlist = await Files.getDirectory(
                host: kodi.host,
                directory: playlist.file,
                media: .music
            )
                .map(\.file)
            songs = kodi.library.songs
                .filter { playlist.contains($0.file) }
            status = songs.isEmpty ? .empty : .ready
        }
        .animation(.default, value: songs)
    }
}
