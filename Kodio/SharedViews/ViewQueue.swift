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
            ViewQueueArtAndPlayer()
            ViewQueueList()
                .frame(minWidth: 400)
        }
#endif
#if os(iOS)
        VStack {
            ViewQueueArtAndPlayer()
            ViewQueueList()
                .padding(.horizontal)
        }
#endif
    }
}

extension ViewQueue {
    
    struct ViewQueueArtAndPlayer: View {
        /// The Player model
        @EnvironmentObject var player: Player
        /// The state of rotating LP
        @State var playing: Bool = false
        /// The view
        var body: some View {
            VStack {
                Text("Playing queue")
                    .font(.title)
                    .padding()
                ZStack {
                    ViewKodiRotatingIcon(animate: $playing)
                        .frame(width: 300)
                        .padding(.leading, 120)
                    /// The 'now playing' thumbnail
                    ViewArtPlayer(item: player.item, size: 300)
                        .cornerRadius(4)
                        .padding(.trailing, 120)
                }
                .padding()
                /// Rotating LP when opening this view
                .onAppear {
                    playing = player.properties.playing
                }
                /// Rotating LP when start/pauze player
                .onChange(of: player.properties) { properties in
                    playing = properties.playing
                }
                HStack {
                    ViewPlayerButtons()
                }
                .padding()
                Spacer()
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
