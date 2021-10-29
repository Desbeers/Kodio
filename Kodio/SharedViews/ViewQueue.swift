//
//  ViewQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewQueue: View {
    /// The Queue model
    @EnvironmentObject var queue: Queue
    /// The view
    var body: some View {
#if os(macOS)
        HStack {
            VStack {
                ViewQueueArt()
                ViewPlayerButtons()
                Spacer(minLength: 100)
            }
            ViewSongsList(songs: queue.songs)
                .frame(minWidth: 400)
        }
#endif
#if os(iOS)
        VStack {
            ViewQueueArt()
            ViewSongsList(songs: queue.songs)
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
}
