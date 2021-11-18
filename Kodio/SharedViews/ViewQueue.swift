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
                    .toolbar(basic: true)
            }
            .frame(minWidth: 300, minHeight: 600, alignment: .top)
            list
                .frame(minWidth: 400, minHeight: 600)
        }
#endif
#if os(iOS)
        VStack {
            art
            list
                .padding(.horizontal)
                .toolbar(basic: true)
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
        VStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(library.getSongsFromQueue()) { song in
                        ViewSongsListRow(song: song, selectedAlbum: nil)
                            .id(song.songID)
                            .opacity(song.queueID < player.properties.queueID ? 0.5 : 1)
                    }
                }
                .listStyle(PlainListStyle())
                /// Scroll to the item that is playing
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
    }
}
