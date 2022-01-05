//
//  ViewLibraryList.swift
//  Kodio (macOS)
//
//  Created by Nick Berendsen on 05/01/2022.
//

import SwiftUI

struct ViewLibraryTableButton: View {
    
    /// The AppState model
    @EnvironmentObject var appState: AppState
    
    let button = Library.LibraryListItem(title: "View Library in a table",
                                 subtitle: "A table view",
                                 empty: "Your library is empty",
                                 icon: "tablecells",
                                 media: .albumArtists)
    
    var body: some View {
        Section(header: Text("Experimental")) {
            NavigationLink(destination: ViewLibraryTable()) {
                Label(button.title, systemImage: button.icon)
            }
        }
    }
}

struct ViewLibraryTable: View {
    /// The Library model
    @EnvironmentObject var library: Library
    //@State var sortOrder: [KeyPathComparator<Library.SongItem>] = [ .init(\.title, order: SortOrder.forward)]
    @State private var selection = Set<Library.SongItem.ID>()
    
    @State var sortOrder = [KeyPathComparator(\Library.SongItem.title)]
    
    /// State of filtering the library
    @State var filtering = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Table(library.filteredContent.genres) {
                    TableColumn("Genres") { genre in
                        Button(
                            action: {
                                Task.detached(priority: .userInitiated) {
                                    _ = await Library.shared.toggleGenre(genre: genre)
                                }
                            },
                            label: {
                                Text(genre.title)
                                    .foregroundColor(genre == library.genres.selected ? Color.accentColor : Color.primary)
                            })
                            .buttonStyle(.plain)
                    }
                }
                .id(library.filteredContent.genres)
                Table(library.filteredContent.artists) {
                    TableColumn("Artists") { artist in
                        Button(
                            action: {
                                Task.detached(priority: .userInitiated) {
                                    _ = await Library.shared.toggleArtist(artist: artist)
                                }
                            },
                            label: {
                                Text(artist.title)
                                    .foregroundColor(artist == library.artists.selected ? Color.accentColor : Color.primary)
                            })
                            .buttonStyle(.plain)
                    }
                }
                .id(library.filteredContent.artists)
                Table(library.filteredContent.albums) {
                    TableColumn("Albums") { album in
                        Button(
                            action: {
                                Task.detached(priority: .userInitiated) {
                                    _ = await Library.shared.toggleAlbum(album: album)
                                }
                            },
                            label: {
                                Text(album.title)
                                    .foregroundColor(album == library.albums.selected ? Color.accentColor : Color.primary)
                            })
                            .buttonStyle(.plain)
                    }
                }
                .id(library.filteredContent.albums)
            }
            Table(songTable, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("􀊵", value: \.rating) { song in
                    Image(systemName: song.rating == 0 ? "heart" : "heart.fill")
                }
                .width(20)
                TableColumn("􀅉", value: \.playCount) { song in
                    Text("\(song.playCount)")
                }
                .width(20)
                TableColumn("Title", value: \.title) { song in
                    Text(song.title)
                        .contextMenu {
                            songActions(song: song)
                        }
                }
                TableColumn("Artist", value: \.subtitle)
                TableColumn("Album", value: \.details)
                TableColumn("Last Played", value: \.lastPlayed)
            }
            .id(library.filteredContent.songs)
        }
        .toolbar {
            VStack(alignment: .leading) {
            Text("This is an highly experimental View to show the library in a table")
            Text("Not yet very fuctional...")
                    .font(.caption)
            }
            //.frame(maxWidth: .infinity, alignment: .leading)
            
        }
    }
    var songTable: [Library.SongItem] {
        return library.filteredContent.songs
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
