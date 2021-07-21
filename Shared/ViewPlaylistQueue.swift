///
/// ViewPlayqueue.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewPlaylistQueue (view)

struct ViewPlaylistQueue: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            List {
                if kodi.playlists.queue.isEmpty {
                    Text("The playlist queue is empty.")
                        .font(.headline)
                        .padding(.top)
                }
                ForEach(kodi.playlists.queue) { song in
                    VStack {
                        HStack {
                            ViewPlaylistQueueButton(song: song)
                                .opacity(song.playlistID < kodi.player.properties.playlistPosition ? 0.5 : 1)
                            /// Dumb-down for the iPhone
                            if AppState.shared.userInterface != .iPhone {
                                Spacer()
                                Menu(
                                    content: {
                                        ViewPlaylistQueueMenuButtons(song: song)
                                    },
                                    label: {
                                        Image(systemName: "ellipsis")
                                    })
                                    .menuStyle(BorderlessButtonMenuStyle())
                                    .frame(width: 40)
                            }
                        }
                        if kodi.player.item.songID == song.songID {
                            ViewPlaylistQueueProgressView()
                        }
                    }
                    .contextMenu {
                        ViewPlaylistQueueMenuButtons(song: song)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .id(song.songID)
                }
                .onMove(perform: move)
            }
            .id(kodi.playlists.queueListID)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    proxy.scrollTo(kodi.player.item.songID, anchor: .center)
                }
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        kodi.sendPlaylistMove(fromPosition: source.first!, toPosition: destination)
        kodi.playlists.queue.move(fromOffsets: source, toOffset: destination)
    }
}

// MARK: - ViewPlaylistQueueButton (view)

struct ViewPlaylistQueueButton: View {
    let song: SongFields
    var body: some View {
        Button(
            action: {
                KodiClient.shared.sendSongAndPlay(song: song)
            },
            label: {
                Label(
                    title: {
                        HStack {
                            ViewArtSong(song: song)
                            Divider()
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.headline)
                                Text(song.artist.joined(separator: " & "))
                                    .font(.subheadline)
                                Text(song.album)
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        .lineLimit(1) },
                    icon: {
                        Image(systemName: KodiClient.shared.getSongListIcon(itemID: song.songID))
                    }
                )
                .labelStyle(ViewSongsStyleLabel())
            }
        )
    }
}

// MARK: - ViewPlaylistQueueMenuButtons (view)

/// Menu is reachable via right-click and via menu button,
/// so in a seperaie View to avoid duplicating.
struct ViewPlaylistQueueMenuButtons: View {
    let song: SongFields
    var body: some View {
        Button("View this song in your library") {
            KodiClient.shared.jumpTo(song)
        }
        Divider()
        Button("Remove this song from the queue") {
            KodiClient.shared.sendPlaylistAction(api: .playlistRemove, playlistPosition: song.playlistID)
        }
    }
}

// MARK: - ViewPlaylistQueueProgressView (view)

struct ViewPlaylistQueueProgressView: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// A timer for the song progress view
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    /// The view
    var body: some View {
        ProgressView(value: Double(kodi.player.properties.percentage), total: 100)
            .onReceive(timer) { _ in
                /// Only update the progress view when we are actualy playing
                if kodi.player.properties.speed == 1 {
                    kodi.getPlayerProperties(playerItem: false)
                }
            }
            .progressViewStyle(ViewPlaylistQueueStyleProgressView())
            .padding(.horizontal)
    }
}

// MARK: - ViewPlaylistQueueStyleProgressView (view)

/// The style for the progress of a song
struct ViewPlaylistQueueStyleProgressView: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(Color.green)
    }
}
