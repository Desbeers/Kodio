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
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The status of loading the queue
    @State private var status: ViewStatus = .loading
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
        .task(id: kodi.player.playlistUpdate) {
            getCurrentPlaylist()
        }
        .onChange(of: kodi.player.properties.playlistID) {
            getCurrentPlaylist()
        }
        /// Start or stop the animation
        .task(id: kodi.player.properties.speed) {
            rotate = kodi.player.properties.speed == 1 ? true : false
        }
    }
    /// The content of the View
    var content: some View {
        HStack(alignment: .center) {
            HStack {
                switch kodi.player.properties.playlistID {
                case .audio:
                    PartsView.RotatingRecord(
                        title: kodi.player.currentItem?.title,
                        subtitle: kodi.player.currentItem?.subtitle ?? "",
                        details: kodi.player.currentItem?.details ?? "",
                        rotate: rotate
                    )
                    itemsList
                default:
                    PartsView.RotatingTape(
                        title: kodi.player.currentItem?.title,
                        subtitle: kodi.player.currentItem?.subtitle ?? "",
                        details: kodi.player.currentItem?.details ?? "",
                        rotate: rotate
                    )
                    itemsList
                }
            }
        }
    }
    /// The list of items
    @ViewBuilder var itemsList: some View {
        if let items = kodi.player.currentPlaylist {
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
                }
                .scrollPosition(id: $scrollID, anchor: .center)
                .scrollTargetLayout()
                .animation(.smooth, value: scrollID)
                .onAppear {
                    self.scrollID = kodi.player.currentItem?.id
                }
                .onChange(of: kodi.player.currentItem?.id) {
                    if let id = kodi.player.currentItem?.id {
                        self.scrollID = id
                    }
                }
            }
        }
    }
}
extension QueueView {

    /// Get the current playlist
    @MainActor
    func getCurrentPlaylist() {
        if let queue = kodi.player.currentPlaylist, !queue.isEmpty {
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
    @ViewBuilder
    func queueItem(item: any KodiItem, single: Bool = false) -> some View {
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
