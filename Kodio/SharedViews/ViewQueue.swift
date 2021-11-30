//
//  ViewQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the song queue
struct ViewQueue: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The Player model
    @EnvironmentObject var player: Player
    /// The current queue list
    @State var queue: [Library.SongItem] = []
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
    /// - Note: The edit mode is a bit unstable; this will keep an eye on it
    @State var mode: EditMode = .inactive
    /// The view
    var body: some View {
        NavigationView {
            VStack {
                art
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
                ForEach(queue) { song in
                    ViewSong(song: song, selectedAlbum: nil)
                        .id(song.queueID)
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
            /// Load the songs for the queue
            .task {
                logger("Loading queue")
                queue = library.getSongsFromQueue()
            }
            /// Update the list when the queue has changed
            .onChange(of: player.queueItems) { _ in
                logger("Reloading queue")
                queue = library.getSongsFromQueue()
            }
            /// Scroll to the active song when it changed
            .onChange(of: player.properties) { item in
                withAnimation(.linear(duration: 1)) {
                    proxy.scrollTo(item.queueID, anchor: .center)
                }
            }
        }
    }
    /// Move a song to a different location of the queue
    func move(from source: IndexSet, to destination: Int) {
        queue.move(fromOffsets: source, toOffset: destination)
        queue = reorder()
        Task {
            await player.updatePlaylist(songs: queue)
        }
    }
    /// Delete a song from the queue
    /// - Note: I can't use ``.onDelete(perform: )`` because there are also other swipe actions
    func delete(song: Library.SongItem) {
        queue.remove(at: song.queueID)
        queue = reorder()
        Task {
            await player.updatePlaylist(songs: queue)
        }
    }
    /// Reorder the songID's so we don't have to reload the whole queue
    func reorder() -> [Library.SongItem] {
        var newQueue: [Library.SongItem] = []
        for (index, song) in queue.enumerated() {
            var newSong = song
            newSong.queueID = index
            newQueue.append(newSong)
        }
        return newQueue
    }
}
