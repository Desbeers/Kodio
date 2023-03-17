//
//  QueueView.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Queue View
struct QueueView: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiPlayer model
    @EnvironmentObject var player: KodiPlayer
    /// The state of loading the queue
    @State var state: AppState.State = .loading
    /// The list of items
    @State private var items: [any KodiItem] = []
    /// Animation toggle because we can't use the items list because its a Protocol
    @State private var animationToggle: Bool = false
    /// Rotate the record
    @State private var rotate: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Text("Now Playing")
                .font(.title)
                .modifier(PartsView.ListHeader())
            switch state {
            case .loading:
                PartsView.LoadingState(message: "Loading the playlist...")
            case .empty:
                PartsView.LoadingState(message: appState.selection?.empty ?? "", icon: appState.selection?.sidebar.icon)
            case .ready:
                HStack(alignment: .center) {
                    VStack {

                        switch player.properties.playlistID {
                        case .audio:
                            PartsView.RotatingRecord(title: player.currentItem?.title,
                                                     subtitle: player.currentItem?.subtitle ?? "",
                                                     details: player.currentItem?.details ?? "",
                                                     rotate: $rotate
                            )
                        default:
                            PartsView.RotatingTape(title: player.currentItem?.title,
                                                     subtitle: player.currentItem?.subtitle ?? "",
                                                     details: player.currentItem?.details ?? "",
                                                     rotate: $rotate
                            )
                        }
                    }

                    switch items.count {
                    case 1:
                        queueItem(item: items.first!, single: true)
                    default:
                        ScrollView {
                            ScrollViewReader { proxy in
                                LazyVStack {
                                    ForEach(items, id: \.id) { item in
                                        queueItem(item: item)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                                .task(id: player.currentItem?.id) {
                                    withAnimation(.linear(duration: 1)) {
                                        proxy.scrollTo(player.currentItem?.id, anchor: .center)
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
        .animation(.default, value: animationToggle)
        .task(id: player.playlistUpdate) {
            if let queue = player.currentPlaylist, !queue.isEmpty {
                state = .ready
                items = queue
            } else {
                state = .empty
                items = []
            }
            animationToggle.toggle()
        }
        .task(id: player.properties.speed) {
            rotate = player.properties.speed == 1 ? true : false
        }
    }
}

extension QueueView {

    /// SwiftUI View for an item in the queue
    /// - Parameters:
    ///   - item: The `KodiItem`
    ///   - single: Bool if there is only one item in the queue
    /// - Returns: A View
    @ViewBuilder func queueItem(item: any KodiItem, single: Bool = false) -> some View {
        switch item {
        case let song as Audio.Details.Song:
            SongsView.Song(song: song, album: nil)
                .id(song.songID)
        case let song as Audio.Details.Stream:
            if let stream = radioStations.first(where: {$0.file.contains(song.title)}) {
                VStack {
                    Label(stream.station, systemImage: "antenna.radiowaves.left.and.right")
                        .font(.title)
                        .padding(.bottom)
                    Text(stream.description)
                        .font(.caption)
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
                .padding()
            }
        case let musicVideo as Video.Details.MusicVideo:
            if single {
                KodiArt.Poster(item: musicVideo)
                    .cornerRadius(10)
                    .padding()
            } else {
                MusicVideosView.MusicVideo(musicVideo: musicVideo)
                    .id(musicVideo.id)
            }
        default:
            KodiArt.Poster(item: item)
                .cornerRadius(10)
                .padding()
        }
    }
}
