//
//  ViewSongsTable.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A View with songs in a table
struct ViewSongsTable: View {
    /// The list of songs
    let songs: [Library.SongItem]
    /// The ID of the song list
    let listID: UUID
    /// The optional selected album
    let selectedAlbum: Library.AlbumItem?
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
                        .onTapGesture {
                            Task {
                                await Library.shared.favoriteSongToggle(song: song)
                            }
                        }
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
                            ViewSongActions(song: song)
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
                ForEach(songs.sorted(using: sortOrder)) { item in
                    TableRow(item)
                }
            }
            .id(listID)
            ViewSongsPlayButtons(songs: songs, selectedAlbum: selectedAlbum)
                .padding(.bottom)
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
}
