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
    @Environment(AppState.self) private var appState
    /// The KodiPlayer model
    @Environment(KodiPlayer.self) private var player
    /// The status of loading the queue
    @State var status: ViewStatus = .loading
    /// The list of items
    @State private var items: [any KodiItem] = []
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The ID of the focussed scroll item
    @State private var scrollID: String?
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            Text("Now Playing")
                .font(.title)
                .modifier(PartsView.ListHeader())
            switch status {
            case .ready:
                content
            default:
                status.message(router: appState.selection)
            }
        }
        .animation(.default, value: status)
        /// Update the current playlist
        .task(id: player.playlistUpdate) {
            getCurrentPlaylist()
        }
        .onChange(of: player.properties.playlistID) {
            getCurrentPlaylist()
        }
        /// Start or stop the animation
        .task(id: player.properties.speed) {
            rotate = player.properties.speed == 1 ? true : false
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
                        rotate: rotate
                    )
                    itemsList
                default:
                    PartsView.RotatingTape(
                        title: player.currentItem?.title,
                        subtitle: player.currentItem?.subtitle ?? "",
                        details: player.currentItem?.details ?? "",
                        rotate: rotate
                    )
                    itemsList
                }
            }
        }
    }
    /// The list of items
    @ViewBuilder var itemsList: some View {
        if let items = player.currentPlaylist {
            switch items.count {
            case 1:
                if let item = items.first {
                    queueItem(item: item, single: true)
                }
            default:
                ScrollView {
                    LazyVStack {
                        ForEach(items, id: \.id) { item in
                            queueItem(item: item)
                                .scrollTransition(.animated) { content, phase in
                                    content
                                        .opacity(phase != .identity ? 0.3 : 1)
                                }
                            Divider()
                                .padding(.leading)
                        }
                    }
                    .padding()
                    .task(id: player.currentItem?.id) {
                        if let id = player.currentItem?.id {
                            withAnimation(.linear(duration: 1)) {
                                self.scrollID = id
                            }
                        }
                    }
                }
                .scrollPosition(id: $scrollID, anchor: .center)
                .scrollTargetLayout()
            }
        }
    }
}
extension QueueView {

    /// Get the current playlist
    @MainActor func getCurrentPlaylist() {
        if let queue = player.currentPlaylist, !queue.isEmpty {
            status = .ready
        } else {
            status = .empty
        }
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
                MusicVideosView.ListItem(musicVideo: musicVideo)
                    .id(musicVideo.id)
            }
        default:
            KodiArt.Poster(item: item)
                .cornerRadius(10)
                .padding()
        }
    }
}
