//
//  ViewSongsListRow.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// List a song in a row
/// - Note: Shared by ``ViewSongs`` and ``ViewQueue``
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
        .contextMenu {
            songActions(song: song)
        }
        .swipeActions(edge: .leading) {
            songActions(song: song)
        }
        .id(song.songID)
    }
}

extension ViewSongsListRow {
    
    /// Art or track number at the start of a row
    /// - Note: when viewing an album it will be the track number, else album art
    @ViewBuilder var leading: some View {
        if Library.shared.filter == .album, AppState.shared.showSheet == false {
            Text(String(song.track))
                .font(.headline)
                .frame(width: 40, height: 40)
        } else {
            ViewArtSong(song: song, size: 40)
                .frame(width: 40, height: 40)
        }
    }
    
    /// The icon for the song item
    @ViewBuilder var icon: some View {
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

    /// The label style for a song item in the list
    struct LabelStyleSongs: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon.foregroundColor(.accentColor).frame(width: 24)
                configuration.title
            }
        }
    }
    
    /// Swipe and *right click* actions.
    /// - Parameter song: The `SongItem` struct
    /// - Returns: A `View` with action buttons
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
                Library.shared.favoriteSongToggle(song: song)
            },
            label: {
                Label(song.rating == 0 ? "Add to favorites" : "Remove from favorites", systemImage: song.rating == 0 ? "heart" : "heart.slash")
            }
        )
            .tint(.red.opacity(0.6))
    }
}