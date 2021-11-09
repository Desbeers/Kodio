//
//  ViewSongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The list of songs
struct ViewSongs: View {
    /// The list of songs
    let songs: [Library.SongItem]
    /// The optional selected album
    let selectedAlbum: Library.AlbumItem?
    /// The view
    var body: some View {
        VStack {
            if !songs.isEmpty {
                header
            }
            list
        }
    }
}

extension ViewSongs {
    
    /// The header above the list of songs
    @ViewBuilder var header: some View {
        let count = songs.count
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: selectedAlbum == nil ? .track : .album)
                        Player.shared.sendSongsAndPlay(songs: songs)
                    },
                    label: {
                        Label("Play \(count == 1 ? "song" : "songs")", systemImage: "play.fill")
                    }
                )
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: selectedAlbum == nil ? .track : .album)
                        Player.shared.sendSongsAndPlay(songs: songs, shuffled: true)
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
            ForEach(songs) { song in
                ViewSongsListRow(song: song, selectedAlbum: selectedAlbum)
                    .modifier(ViewModifierSongs(song: song, selectedAlbum: selectedAlbum))
#if os(macOS)
                Divider()
#endif
            }
        }
        /// Speed up iOS
        .id(Library.shared.songs.listID)
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
