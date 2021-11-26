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
    /// The song in this row
    let song: Library.SongItem
    /// The optional selected album
    let selectedAlbum: Library.AlbumItem?
    /// The Player model
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        VStack(alignment: .leading) {
            Label {
                HStack {
                    leading
                    Divider()
                    ViewLibraryItemDetails(item: song)
                }
            } icon: {
                icon
            }
            Divider()
        }
        .labelStyle(LabelStyleSongs())
        .contextMenu {
            songActions(song: song)
        }
        .swipeActions(edge: .leading) {
            songActions(song: song)
        }
    }
}

extension ViewSongsListRow {
    
    /// Art or track number at the start of a row
    /// - Note: when viewing an album it will be the track number, else album art
    @ViewBuilder var leading: some View {
        if selectedAlbum != nil, AppState.shared.showSheet == false, song.track > 0 {
            Text(String(song.track))
                .font(.headline)
                .frame(width: 40, height: 40)
        } else {
            ViewRemoteArt(item: song, art: .thumbnail)
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
                Task.detached(priority: .userInitiated) {
                    await player.playSong(song: song)
                }
            },
            label: {
                Label("Play", systemImage: "play")
            }
        )
            .tint(.accentColor)
        /// Button to reset the play count
        Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await Library.shared.resetSong(song: song)
                }
            },
            label: {
                Label("Reset", systemImage: "gobackward.minus")
            }
        )
            .tint(.green.opacity(0.6))
        /// Button to add or remove a song from favorites
        Button(
            action: {
                Task {
                    await Library.shared.favoriteSongToggle(song: song)
                }
            },
            label: {
                Label(song.rating == 0 ? "Favorite" : "Unfavorite", systemImage: song.rating == 0 ? "heart" : "heart.slash")
            }
        )
            .tint(.red.opacity(0.6))
    }
}

/// View modifier for a `Library/SongItem`
struct ViewModifierSongItem: ViewModifier {
#if os(macOS)
    func body(content: Content) -> some View {
        content
    }
#endif
#if os(iOS)
    func body(content: Content) -> some View {
        /// - Note: Song rows already have a `Divider` 
        content
            .listRowSeparator(.hidden)
    }
#endif
}
