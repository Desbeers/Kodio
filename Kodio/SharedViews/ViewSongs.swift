//
//  ViewSongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

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
                header
            }
            list
        }
    }
}

extension ViewSongs {
    
    /// The header above the list of songs
    @ViewBuilder var header: some View {
        let count = library.filteredContent.songs.count
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.albums.selected == nil ? .track : .album)
                        player.sendSongsAndPlay(songs: library.filteredContent.songs)
                    },
                    label: {
                        Label("Play \(count == 1 ? "song" : "songs")", systemImage: "play.fill")
                    }
                )
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.albums.selected == nil ? .track : .album)
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
    
    /// The list of songs
    var list: some View {
        List {
            ForEach(library.filteredContent.songs) { song in
                ViewSongsListRow(song: song)
                    .modifier(ViewModifierSongs(song: song, selectedAlbum: library.albums.selected))
#if os(macOS)
                Divider()
#endif
            }
        }
        /// Speed up iOS
        .id(library.songs.listID)
        .listStyle(PlainListStyle())
    }
    
    /// Display disc number only once and only when an album is selected that has more than one disc
    struct ViewModifierSongs: ViewModifier {
        /// The song item
        let song: Library.SongItem
        /// The optional selected album
        let selectedAlbum: Library.AlbumItem?
        /// The view
        func body(content: Content) -> some View {
            if let album = selectedAlbum, album.totalDiscs > 1, song.disc != 0, song.track == 1 {
                HStack {
                    Image(systemName: "\(song.disc).square")
                        .font(.title)
                    Spacer()
                }
                .padding(.bottom)
                content
            } else {
                content
            }
        }
    }
}
