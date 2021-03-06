//
//  ViewSongs.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// The list of songs
struct ViewSongs: View {
    /// The list of songs
    let songs: [Library.SongItem]
    /// The ID of the song list
    let listID: UUID
    /// The optional selected album
    let selectedAlbum: Library.AlbumItem?
    /// The view
    var body: some View {
        VStack {
            ViewSongsPlayButtons(songs: songs, selectedAlbum: selectedAlbum)
            list
        }
        .id(listID)
        .frame(maxWidth: .infinity)
    }
}

extension ViewSongs {

    /// The list of songs
    var list: some View {
        ScrollView {
            LazyVStack {
                ForEach(songs) { song in
                    ViewSong(song: song, selectedAlbum: selectedAlbum)
                        .padding(.horizontal)
                        .modifier(ViewModifierSongs(song: song, selectedAlbum: selectedAlbum))
                }
            }
            .padding(.top)
        }
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
                Image(systemName: "\(song.disc).square")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                content
            } else {
                content
            }
        }
    }
}

/// View play/shuffle buttons for current selection of songs
/// - Note: View is shared between ``ViewSongs`` and ``ViewSongsTable``
struct ViewSongsPlayButtons: View {
    /// Current list of songs
    let songs: [Library.SongItem]
    /// The optional selected album
    let selectedAlbum: Library.AlbumItem?
    /// The View
    var body: some View {
        let count = songs.count
        /// - Note: Don't add more than 500 songs to the queue; that makes no sense
        if count <= 500 {
            HStack {
                Button(
                    action: {
                        Task.detached(priority: .userInitiated) {
                            await Player.shared.playPlaylist(songs: songs,
                                                             album: selectedAlbum == nil ? false : true)
                        }
                    },
                    label: {
                        Label("Play \(count == 1 ? "song" : "songs")", systemImage: "play.fill")
                    }
                )
                Button(
                    action: {
                        Task.detached(priority: .userInitiated) {
                            await Player.shared.playPlaylist(songs: songs,
                                                             album: selectedAlbum == nil ? false : true,
                                                             shuffled: true)
                        }
                    },
                    label: {
                        Label("Shuffle \(count == 1 ? "song" : "songs")", systemImage: "shuffle")
                    }
                )
            }
            .padding(.top)
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            /// - Note: iOS doesn't like two buttons in a listrow unless you give it a style
            .iOS {$0
            .buttonStyle(.bordered)
            }
        } else {
            EmptyView()
        }
    }
}
