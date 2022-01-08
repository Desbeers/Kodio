//
//  ViewSongsTable.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A View with songs in a table
struct ViewSongsTable: View {
    /// The list of songs
    let songs: [Library.SongItem]
    /// The ID of the song list
    let listID: UUID
    /// Sort order for the table
    @State var sortOrder: [KeyPathComparator<Library.SongItem>] = [ .init(\.subtitle, order: SortOrder.forward)]
    /// The selected items in the table
    @State private var selection = Set<Library.SongItem.ID>()
    /// The View
    var body: some View {
        VStack(spacing: 0) {
            Table(selection: $selection, sortOrder: $sortOrder) {
                TableColumn("􀊵", value: \.rating) { song in
                    Image(systemName: song.rating == 0 ? "heart" : "heart.fill")
                }
                .width(20)
                TableColumn("􀅉", value: \.playCount) { song in
                    Text("\(song.playCount)")
                }
                .width(20)
                TableColumn("Art") { song in
                    ViewRemoteArt(item: song, art: .thumbnail)
                        .frame(width: 20, height: 20)
                }
                .width(40)
                TableColumn("Title", value: \.title) { song in
                    Text(song.title)
                        .contextMenu {
                            songActions(song: song)
                        }
                }
                TableColumn("Artist", value: \.subtitle)
                TableColumn("Album", value: \.details)
                TableColumn("Last Played", value: \.lastPlayed) { song in
                    if let date = date(string: song.lastPlayed) {
                        Text(date, style: .date)
                    } else {
                        Text("Never played")
                    }
                }
            } rows: {
                ForEach(songTable) { item in
                    TableRow(item)
                }
            }
            .id(listID)
        }
    }
    
    /// Convert a 'string date' to a real ``Date``
    /// - Parameter string: A 'Kodi String Date'
    /// - Returns: A real ``Date``
    func date(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: string)
    }

    /// Get a sorted list of songs
    var songTable: [Library.SongItem] {
        return songs
            .sorted(using: sortOrder)
    }
    
    /// Swipe and *right click* actions.
    /// - Parameter song: The `SongItem` struct
    /// - Returns: A `View` with action buttons
    @ViewBuilder func songActions(song: Library.SongItem) -> some View {
        /// Button to play this song
        Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await Player.shared.playSong(song: song)
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
