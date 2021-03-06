//
//  ViewQueue.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// View the song queue
struct ViewQueue: View {
    /// The Player model
    @EnvironmentObject var player: Player
#if os(macOS)
    /// The view
    var body: some View {
        HStack {
            VStack {
                art
                    .toolbarButtons(basic: true)
            }
            .frame(minWidth: 300, minHeight: 600, alignment: .top)
            list
                .frame(minWidth: 400, minHeight: 600)
        }
    }
#endif
#if os(iOS)
    /// Edit mode for the list
    /// - Note: The edit mode is a bit unstable; this will keep an eye on it
    @State var mode: EditMode = .inactive
    /// The view
    var body: some View {
        NavigationView {
            VStack {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    art
                }
                list
                    .toolbarButtons(basic: true)
                    .padding()
                
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .environment(\.editMode, $mode)
        }
    }
#endif
}

extension ViewQueue {
    
    /// The current artwork of the player
    var art: some View {
        VStack {
            Text("Playing queue")
                .font(.title)
                .padding()
            ZStack {
                ViewRotatingRecord()
                    .frame(width: 150, height: 150)
                    .padding(.leading, player.properties.playing ? 80 : 0)
                ViewPlayerArt(item: player.item, size: 150, fallback: "QueueAlbum")
                    .frame(width: 150, height: 150)
                    .padding(.trailing, player.properties.playing ? 60 : 0)
                    .cornerRadius(2)
            }
            .animation(.default, value: player.properties.playing)
            .transition(.move(edge: .leading))
            .padding()
        }
    }
    
    /// The list of songs in the queue
    var list: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(player.queueSongs) { song in
                    ViewSong(song: song, selectedAlbum: nil)
                        .id(song.songID)
                        .opacity(song.queueID < player.properties.queueID ? 0.5 : 1)
                        .swipeActions(edge: .trailing) {
                            /// Button to delete an item from the queue
                            Button(
                                role: .destructive,
                                action: {
                                    delete(song: song)
                                },
                                label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            )
                        }
                }
                .onMove(perform: move)
            }
            .listStyle(.plain)
            .task {
                 withAnimation(.linear(duration: 1)) {
                     /// - Note: This does not works correct on macOS with a long list; it partly scrolls
                     proxy.scrollTo(player.item.songID, anchor: .center)
                 }
            }
            /// Scroll to the active song when it changed
            .onChange(of: player.item) { item in
                withAnimation(.linear(duration: 1)) {
                    proxy.scrollTo(item.songID, anchor: .center)
                }
            }
        }
    }
    /// Move a song to a different location of the queue
    func move(from source: IndexSet, to destination: Int) {
        player.queueSongs.move(fromOffsets: source, toOffset: destination)
        player.queueSongs = reorder()
        Task {
            await player.updatePlaylist(songs: player.queueSongs)
        }
    }
    /// Delete a song from the queue
    /// - Note: I can't use ``.onDelete(perform: )`` because there are also other swipe actions
    func delete(song: Library.SongItem) {
        player.queueSongs.remove(at: song.queueID)
        player.queueSongs = reorder()
        Task {
            await player.updatePlaylist(songs: player.queueSongs)
        }
    }
    /// Reorder the songID's so we don't have to reload the whole queue
    func reorder() -> [Library.SongItem] {
        var newQueue: [Library.SongItem] = []
        for (index, song) in player.queueSongs.enumerated() {
            var newSong = song
            newSong.queueID = index
            newQueue.append(newSong)
        }
        return newQueue
    }
}
