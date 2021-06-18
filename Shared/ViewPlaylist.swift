///
/// ViewPlaylist.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewPlaylist (view)

struct ViewPlaylist: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// A timer for the song progress view
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
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
                        Button { kodi.sendSongAndPlay(song: song) }
                            label: {
                                Label {
                                    HStack {
                                        ViewArtSong(song: song)
                                        Divider()
                                        VStack(alignment: .leading) {
                                            Text(song.title).font(.headline)
                                            Group {
                                                Text(song.artist.joined(separator: " & "))
                                                Text("\(song.album)")
                                            }
                                            .font(.caption)
                                        }
                                        Spacer()
                                    }
                                    .lineLimit(1)
                                } icon: {
                                    Image(systemName: kodi.getSongListIcon(itemID: song.songID))
                                }
                                .labelStyle(ViewSongsStyleLabel())
                                .opacity(song.playlistID < kodi.player.properties.playlistPosition ? 0.5 : 1)
                        }
                        Spacer()
                        /// Dumb-down for the iPhone
                        if kodi.userInterface != .iPhone {
                            Menu() {
                                Button("View this song in your library") {
                                    kodi.jumpTo(song)
                                }
                                Divider()
                                Button("Remove this song from the queue") {
                                    kodi.sendPlaylistAction(api: .playlistRemove, playlistPosition: song.playlistID)
                                }
                            }
                            label: {
                                Image(systemName: "ellipsis")
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                            .frame(width: 40)
                        }
                    }
                    if kodi.player.item.songID == song.songID {
                        ProgressView(value: Double(kodi.player.properties.percentage), total: 100)
                            .onReceive(timer) { _ in
                                /// Only update the progress view when we are actualy playing
                                if kodi.player.properties.speed == 1 {
                                    kodi.getPlayerProperties(playerItem: false)
                                }
                            }
                            .progressViewStyle(ViewPlaylistStyleProgressView())
                            .padding(.horizontal)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .id(song.songID)
            }
            .onMove(perform: move)
        }
        .id(kodi.playlists.queueListID)
        .onAppear {
            print("Jump")
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

// MARK: - ViewPlaylistMenu (view)

/// A view with a list of playlists
struct ViewPlaylistMenu: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        Menu("Playlists") {
            ForEach(kodi.playlists.files) { file in
                Button(file.label.removeExtension()) {
                    kodi.getPlaylistSongs(file: file)
                }
            }
        }
    }
}

// MARK: - ViewPlaylistStyleProgressView (view)

/// The style for the progress of a song
struct ViewPlaylistStyleProgressView: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(Color.green)
    }
}
