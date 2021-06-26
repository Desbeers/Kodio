///
/// ViewSongs.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewSongs (view)

/// The main songs view
struct ViewSongs: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The list of songs
    @State var songs = [SongFields]()
    /// The view
    var body: some View {
        SongsViewHeader()
        List {
            ForEach(songs) { song in
                HStack {
                    Button { kodi.sendSongAndPlay(song: song) }
                        label: {
                            Label {
                                HStack {
                                    songsViewRowHeader(song: song)
                                    Divider()
                                    VStack(alignment: .leading) {
                                        Text(song.title)
                                            .font(.headline)
                                        Group {
                                            Text(song.artist.joined(separator: " & "))
                                                .isHidden(kodi.hideArtistLabel(song: song))
                                            Text("\(song.album)")
                                                .isHidden(kodi.filter.songs == .album)
                                        }
                                        .font(.caption)
                                    }
                                    .lineLimit(1)
                                    Spacer()
                                }
                            } icon: {
                                Image(systemName: kodi.getSongListIcon(itemID: song.songID))
                            }
                        }
                        .labelStyle(ViewSongsStyleLabel())
                        .id(song.songID)
                        .padding()
                    Menu() {
                        Button("Add this song to the queue") {
                            kodi.sendPlaylistAction(api: .playlistAdd, songList: [song.songID])
                        }
                    }
                    label: {
                        Image(systemName: "ellipsis")
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .frame(width: 40)
                    .padding(.trailing)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color("SongList"))
                .cornerRadius(5)
            }
        }
        .id(kodi.songListID)
        .onAppear {
            songs = kodi.songsFilter
        }
    }
}

struct SongsViewHeader: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack(alignment: .leading) {
            Text(kodi.songlistHeader)
                .font(.title)
                .padding(.top)
            HStack {
                Button { kodi.sendPlaylistAndPlay(songs: kodi.songsFilter) }
                    label: {
                        Label("Play songs", systemImage: "play")
                    }
                Button { kodi.sendPlaylistAndPlay(songs: kodi.songsFilter, shuffled: true) }
                    label: {
                        Label("Shuffle songs", systemImage: "shuffle")
                    }
                if kodi.albums.selected != nil, !(kodi.albums.selected?.description.isEmpty ?? true) {
                        Spacer()
                        Button("Info") {
                            DispatchQueue.main.async {
                                appState.activeSheet = .viewAlbumInfo
                                appState.showSheet = true
                            }
                        }
                    .foregroundColor(.accentColor)
                }
            }
            .buttonStyle(ViewPlayerStyleButton())
            Divider()
        }
        .padding(.horizontal)
    }
}

// MARK: - songsViewRowHeader (extension)

extension ViewSongs {
    
    /// If an album is selected; we show the track numbers, else the song art.
    /// - Parameter song: The song object
    /// - Returns: Song art or track number
    @ViewBuilder
    func songsViewRowHeader(song: SongFields) -> some View {
        if kodi.filter.songs == .album, song.track != 0 {
            Text(String(song.track))
                .font(.caption)
        } else {
            ViewArtSong(song: song)
        }
    }
}

// MARK: - SongLabelStyle (label style)

struct ViewSongsStyleLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.foregroundColor(.accentColor)
            configuration.title
        }
    }
}
