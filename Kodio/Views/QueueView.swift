//
//  QueueView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the queue
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
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            Text("Now Playing")
                .font(.title)
                .modifier(PartsView.ListHeader())
            switch state {
            case .loading:
                PartsView.LoadingState(message: "Loading the playlist...")
            case .empty:
                PartsView.LoadingState(message: appState.selection.item.empty, icon: appState.selection.item.icon)
            case .ready:
                content
            }
        }
        .animation(.default, value: player.currentItem?.id)
        .animation(.default, value: animationToggle)
        /// Update the current playlist
        .task(id: player.playlistUpdate) {
            getCurrentPlaylist()
        }
        /// Start or stop the animation
        .task(id: player.properties.speed) {
            rotate = player.properties.speed == 1 ? true : false
        }
        .onChange(of: player.properties.playlistID) { _ in
            getCurrentPlaylist()
        }
    }
    /// The content of the View
    var content: some View {
        HStack(alignment: .center) {
            HStack {
                switch player.properties.playlistID {
                case .audio:
                    PartsView.RotatingRecord(
                        title: player.currentItem?.title,
                        subtitle: player.currentItem?.subtitle ?? "",
                        details: player.currentItem?.details ?? "",
                        rotate: $rotate
                    )
                    itemsList
                default:
                    PartsView.RotatingTape(
                        title: player.currentItem?.title,
                        subtitle: player.currentItem?.subtitle ?? "",
                        details: player.currentItem?.details ?? "",
                        rotate: $rotate
                    )
                    itemsList
                }
            }
        }
    }
    /// The list of items
    @ViewBuilder var itemsList: some View {
        switch items.count {
        case 1:
            if let item = items.first {
                queueItem(item: item, single: true)
            }
        default:
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(items, id: \.id) { item in
                            queueItem(item: item)
                            Divider()
                                .padding(.leading)
                        }
                    }
                    .padding()
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
extension QueueView {

    /// Get the current playlist
    @MainActor func getCurrentPlaylist() {
        if let queue = player.currentPlaylist, !queue.isEmpty {
            state = .ready
            items = queue
        } else {
            state = .empty
            items = []
        }
        animationToggle.toggle()
    }
}

extension QueueView {

    /// SwiftUI `View` for a queue item
    /// - Parameters:
    ///   - item: The `KodiItem`
    ///   - single: Bool if there is only one item in the queue
    /// - Returns: A View
    @ViewBuilder func queueItem(item: any KodiItem, single: Bool = false) -> some View {
        switch item {
        case let song as Audio.Details.Song:
            SongView(song: song, album: nil)
                .id(song.id)
        case let song as Audio.Details.Stream:
            if let stream = radioStations.first(where: { $0.file.contains(song.title) }) {
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
