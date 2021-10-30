//
//  ViewSongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View songs

/// The list of songs
struct ViewSongs: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The Player model
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        VStack {
            if !library.filteredContent.songs.isEmpty {
                songsHeader
            }
            ViewSongsList(songs: library.filteredContent.songs)
        }
    }
}

extension ViewSongs {
    /// The header above the list of songs
    @ViewBuilder
    var songsHeader: some View {
        let count = library.filteredContent.songs.count
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.selectedAlbum == nil ? .track : .album)
                        player.sendSongsAndPlay(songs: library.filteredContent.songs)
                    },
                    label: {
                        Label("Play \(count == 1 ? "song" : "songs")", systemImage: "play.fill")
                    }
                )
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.selectedAlbum == nil ? .track : .album)
                        player.sendSongsAndPlay(songs: library.filteredContent.songs, shuffled: true)
                    },
                    label: {
                        Label("Shuffle \(count == 1 ? "song" : "songs")", systemImage: "shuffle")
                    }
                )
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
