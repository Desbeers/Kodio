//
//  ViewQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewQueue: View {
    /// The view
    var body: some View {
#if os(macOS)
        HStack {
            VStack {
                ViewQueueArt()
                ViewPlayerButtons()
                Spacer(minLength: 100)
            }
            ViewQueueList()
                .frame(minWidth: 400)
        }
#endif
#if os(iOS)
        VStack {
            ViewQueueArt()
            ViewQueueList()
                .padding(.horizontal)
            ViewPlayerButtons()
                .padding(40)
        }
#endif
    }
}

extension ViewQueue {
    
    struct ViewQueueArt: View {
        /// The Player model
        @EnvironmentObject var player: Player
        /// The view
        var body: some View {
            VStack {
                Text("Playing queue")
                    .font(.title)
                    .padding()
                ZStack {
                    if player.properties.playing {
                        HStack(alignment: .top) {
                            ViewRotatingRecord()
                                .frame(width: 150, height: 150)
                                .padding(.leading, 68)
                            Spacer()
                        }
                    }
                    HStack(alignment: .center) {
                        ViewArtPlayer(item: player.item, size: 300)
                            .frame(width: 150, height: 150)
                            .cornerRadius(2)
                        Spacer()
                    }
                }
                .animation(.default, value: player.properties.playing)
                .transition(.move(edge: .leading))
                .frame(width: 218)
                .padding()
            }
        }
    }
    
    struct ViewQueueList: View {
        /// The Player model
        @EnvironmentObject var player: Player
        /// The Queue model
        @EnvironmentObject var queue: Queue
        /// The view
        var body: some View {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            Spacer(minLength: 30)
                            ForEach(queue.songs) { song in
                                Button(
                                    action: {
                                        player.sendSongAndPlay(song: song)
                                    }, label: {
                                        ViewQueueListRow(song: song)
                                            .opacity(song.queueID < player.properties.queueID ? 0.5 : 1)
                                    })
                                    .buttonStyle(PlainButtonStyle())
                                    .id(song.songID)
                                Divider()
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    /// Scroll to the item that is playing
                    .onAppear {
                        withAnimation(.linear(duration: 30)) {
                            proxy.scrollTo(player.item.songID, anchor: .center)
                        }
                    }
                    /// Scroll to the active song
                    .onChange(of: player.item) { item in
                        withAnimation(.linear(duration: 30)) {
                            proxy.scrollTo(item.songID, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    struct ViewQueueListRow: View {
        let song: Library.SongItem
        /// The Player model
        @EnvironmentObject var player: Player
        var body: some View {
            Label {
                HStack {
                    ViewArtSong(song: song, size: 40)
                        .frame(width: 40, height: 40)
                    Divider()
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                        Text(song.artists)
                            .font(.subheadline)
                        Text("\(song.album)")
                            .font(.caption)
                    }
                    Spacer()
                }
            } icon: {
                Image(systemName: player.getIcon(for: song))
            }
            /// Make the whole lablel clickable
            .contentShape(Rectangle())
            .labelStyle(LabelStyleQueue())
            .id(song.songID)
        }
    }
    
    /// The label style for a song item in the queue
    struct LabelStyleQueue: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon.foregroundColor(.accentColor)
                configuration.title
            }
        }
    }
}
