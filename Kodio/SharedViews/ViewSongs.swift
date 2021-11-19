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
    /// The songList
    @State private var songList = [Library.SongItem]()
    /// The current page in the view
    @State private var currentPage: Int = 0
    /// The view
    var body: some View {
        VStack {
            list
        }
        .id(songs)
        .frame(maxWidth: .infinity)
    }
}

extension ViewSongs {
    
    /// The header above the list of songs
    @ViewBuilder var header: some View {
        let count = songs.count
        /// - Note: Don't add more than 200 songs to the queue; that makes no sense
        if count <= 200 {
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
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Spacer()
        }
        
    }
    
    /// The list of songs
    var list: some View {
        List {
            header
            ForEach(songList) { song in
                ViewSongsListRow(song: song, selectedAlbum: selectedAlbum)
                    .modifier(ViewModifierSongs(song: song, selectedAlbum: selectedAlbum))
                    .task {
                        /// Check if we have more songs to load
                        if song == songList.last && songList.count < songs.count {
                            currentPage += 1
                            songList += await Library.pager(items: songs, page: currentPage)
                        }
                    }
                    .modifier(ViewModifierLists())
            }
        }
        .task {
            /// Reset the page counter
            currentPage = 0
            /// Get the first page of songs
            songList = await Library.pager(items: songs)
        }
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
