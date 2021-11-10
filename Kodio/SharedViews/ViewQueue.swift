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
    /// The view
    var body: some View {
#if os(macOS)
        HStack {
            VStack {
                art
                ViewPlayerButtons()
                Spacer()
            }
            .frame(minWidth: 300, minHeight: 600)
            list
                .frame(minWidth: 400, minHeight: 600)
        }
#endif
#if os(iOS)
        VStack {
            art
            list
                .padding(.horizontal)
            ViewPlayerButtons()
                .padding(40)
        }
#endif
    }
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
                ViewArtPlayer(item: player.item, size: 150, fallback: "QueueAlbum")
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
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(library.getSongsFromQueue()) { song in
                        ViewSongsListRow(song: song, selectedAlbum: nil)
                        /// - Note: Give it a fixed height, or else macOS does not scroll correct
                            .frame(height: 50)
                            .id(song.songID)
                            .opacity(song.queueID < player.properties.queueID ? 0.5 : 1)
                    }
                }
                .listStyle(PlainListStyle())
                /// Scroll to the item that is playing
                .task {
                    withAnimation(.linear(duration: 1)) {
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
    }
}
