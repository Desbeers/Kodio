//
//  ViewSongsList.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// List songs
/// - Note: Shared by `ViewSongs` and `ViewQueue`
struct ViewSongsList: View {
    /// The song list
    let songs: [Library.SongItem]
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        List {
            ForEach(songs) { song in
                ViewSongsListRow(song: song)
                    .modifier(ViewModifierSongsDisc(song: song, selectedAlbum: library.selectedAlbum))
                    .contextMenu {
                        songActions(song: song)
                    }
                    .swipeActions(edge: .leading) {
                        songActions(song: song)
                    }
                    .id(song.songID)
#if os(macOS)
                Divider()
#endif
            }
        }
        /// Speed up iOS
        .id(library.songListID)
        .listStyle(PlainListStyle())
    }
}

extension ViewSongsList {
    /// An song row in the list
    struct ViewSongsListRow: View {
        let song: Library.SongItem
        /// The Player model
        @EnvironmentObject var player: Player
        /// The view
        var body: some View {
            Label {
                HStack {
                    leading
                    Divider()
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artists)
                            .font(.subheadline)
                        Text("\(song.album)")
                            .font(.caption)
                    }
                    .lineLimit(1)
                    Spacer()
                }
            } icon: {
                icon
            }
            .labelStyle(LabelStyleSongs())
        }
        /// Art or track number
        /// - Note: when viewing an album it will be the track number, else album art
        @ViewBuilder
        var leading: some View {
            if Library.shared.media == .albums, AppState.shared.showSheet == false {
                Text(String(song.track))
                    .font(.headline)
                    .frame(width: 40, height: 40)
            } else {
                ViewArtSong(song: song, size: 40)
                    .frame(width: 40, height: 40)
            }
        }
        @ViewBuilder
        var icon: some View {
            if song.songID == player.item.songID {
                if player.properties.speed == 0 {
                    Image(systemName: "pause.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            } else {
                Image(systemName: song.rating == 0 ? "music.note" : "heart")
            }
        }
    }
    
    /// The label style for a song item in the list
    struct LabelStyleSongs: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon.foregroundColor(.accentColor).frame(width: 24)
                configuration.title
            }
        }
    }
    
    /// Display disc number only once and only when an album is selected that has more than one disc
    struct ViewModifierSongsDisc: ViewModifier {
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
    
    /// Swipe and *right click* actions.
    /// - Parameter song: The `SongItem` struct
    /// - Returns: action buttons
    @ViewBuilder func songActions(song: Library.SongItem) -> some View {
        /// Button to play this song
        Button(
            action: {
                Player.shared.sendSongAndPlay(song: song)
            },
            label: {
                Label("Play", systemImage: "play")
            }
        )
            .tint(.accentColor)
        /// Button to add or remove a song from favorites
        Button(
            action: {
                library.favoriteSongToggle(song: song)
            },
            label: {
                Label(song.rating == 0 ? "Add to favorites" : "Remove from favorites", systemImage: song.rating == 0 ? "heart" : "heart.slash")
            }
        )
            .tint(.red.opacity(0.6))
    }
}
