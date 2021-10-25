//
//  ViewSongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View songs

/// The list of songs
struct ViewSongs: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The Player model
    @EnvironmentObject var player: Player
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            List {
                if !library.filteredContent.songs.isEmpty {
                    songsHeader
                        .id("SongsHeader")
#if os(iOS)
                        .listRowSeparator(.hidden)
#endif
                }
                ForEach(library.filteredContent.songs) { song in
                    ViewSongsListRow(song: song)
                        .modifier(ViewModifierSongsDisc(song: song, selectedAlbum: library.selectedAlbum))
                        .contextMenu {
                            ViewSongsSwipeActions(song: song, library: library)
                        }
                        .swipeActions(edge: .leading) {
                            ViewSongsSwipeActions(song: song, library: library)
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
            .onChange(of: library.scroll) { scroll in
                withAnimation(.linear(duration: 30)) {
                    logger("Song jump \(scroll.song)")
                    proxy.scrollTo(scroll.song, anchor: .center)
                }
            }
        }
    }
}

extension ViewSongs {
    /// The header above the list of songs
    @ViewBuilder
    var songsHeader: some View {
        let count = library.filteredContent.songs.count
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.selectedAlbum == nil ? .track : .album)
                        player.sendSongsAndPlay(songs: library.filteredContent.songs)
                    },
                    label: {
                        Label("Play \(count == 1 ? "song" : "songs")", systemImage: "play.fill")
                    }
                )
                Button(
                    action: {
                        KodiHost.shared.setReplayGain(mode: library.selectedAlbum == nil ? .track : .album)
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
                Image(systemName: player.getIcon(for: song))
            }
            .labelStyle(LabelStyleSongs())
        }
        /// Art or track number
        /// - Note: when viewing an album it will be the track number, else album art
        @ViewBuilder
        var leading: some View {
            if Library.shared.media == .albums, song.track != 0 {
                Text(String(song.track))
                    .font(.headline)
                    .frame(width: 40, height: 40)
            } else {
                ViewArtSong(song: song, size: 40)
                    .frame(width: 40, height: 40)
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
                //Divider()
                content
            } else {
                content
            }
        }
    }
    
    struct ViewSongsSwipeActions: View {
        /// The song item
        let song: Library.SongItem
        /// The Library model
        @State var library: Library
        /// The view
        var body: some View {
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
            /// Buttons to find a song in the library when we are in a smart list
            if library.selectedSmartList != library.allSmartLists[0],
               library.selectedSmartList != library.allSmartLists[1] {
                Button(
                    action: {
                        library.scrollInLibrary(song: song)
                    },
                    label: {
                        Label("Find in library", systemImage: "building.columns")
                    })
                    .tint(.indigo)
            }
        }
    }
    
    /// Menu buttons for a song
    struct ViewSongsMenuButtons: View {
        /// The song item
        let song: Library.SongItem
        /// The Library model
        @State var library: Library
        /// The view
        var body: some View {
            Text(song.title)
            /// Button to add or remove a song from favorites
            Button(
                action: {
                    library.favoriteSongToggle(song: song)
                },
                label: {
                    HStack {
                        Image(systemName: song.rating == 0 ? "heart" : "heart.slash")
                        Text(song.rating == 0 ? "Add to favorites" : "Remove from favorites")
                    }
                }
            )
            /// Buttons to find a song in the library when we are in a smart list
            if library.selectedSmartList != library.allSmartLists[0],
               library.selectedSmartList != library.allSmartLists[1] {
                Divider()
                Button(action: {
                    library.scrollInLibrary(song: song)
                },
                       label: {
                    Text("View '\(song.title)' in your library")
                })
            }
        }
    }
}
