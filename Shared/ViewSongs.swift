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
    /// The songs object
    @StateObject var songs: Songs = .shared
    /// The view
    var body: some View {
        VStack {
            ViewSongsHeader()
            List {
                ForEach(songs.list) { song in
                    ViewSongsListRow(song: song)
                }
            }
            .id(KodiClient.shared.songListID)
            .onAppear {
                print("Songs appear")
            }
        }
    }
}

// MARK: - ViewSongsHeader (view)

struct ViewSongsHeader: View {
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
                Button {
                    appState.tabs.tabDetails = .playqueue
                    kodi.sendPlaylistAndPlay(songs: kodi.songsFilter)
                }
                label: {
                    Label("Play songs", systemImage: "play")
                }
                Button {
                    appState.tabs.tabDetails = .playqueue
                    kodi.sendPlaylistAndPlay(songs: kodi.songsFilter, shuffled: true)
                }
                label: {
                    Label("Shuffle songs", systemImage: "shuffle")
                }
                ViewAlbumDescription(album: Albums.shared.selectedAlbum)
            }
            .buttonStyle(ViewPlayerStyleButton())
            Divider()
        }
        .padding(.horizontal)
    }
}

// MARK: - ViewSongsListRow (view)

/// The row of an song in the list
struct ViewSongsListRow: View {
    /// The song object
    let song: SongFields
    /// The View
    var body: some View {
        HStack {
            Button {
                KodiClient.shared.sendSongAndPlay(song: song)
            } label: {
                ViewSongsListRowLabel(song: song)
            }
            .padding()
            Menu() {
                ViewSongsMenuButtons(song: song)
            }
            label: {
                Image(systemName: "ellipsis")
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .frame(width: 40)
            .padding(.trailing)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            ViewSongsMenuButtons(song: song)
        }
        .background(Color("SongList"))
        .cornerRadius(5)
    }
}

/// If an album is selected; we show the track numbers, else the song art
struct ViewSongsListRowHeader: View {
    let song: SongFields
    var body: some View {
        if Songs.shared.filter == .album, song.track != 0 {
            Text(String(song.track))
                .font(.caption)
        } else {
            ViewArtSong(song: song)
        }
    }
}

/// The label of the songlist button
struct ViewSongsListRowLabel: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The song object
    let song: SongFields
    /// The View
    var body: some View {
        Label {
            HStack {
                ViewSongsListRowHeader(song: song)
                Divider()
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                    Text(song.artist.joined(separator: " & "))
                        .isHidden(kodi.hideArtistLabel(song: song))
                        .font(.subheadline)
                    Text("\(song.album)")
                        .isHidden(Songs.shared.filter == .album)
                        .font(.caption)
                }
                .lineLimit(1)
                Spacer()
            }
        } icon: {
            Image(systemName: kodi.getSongListIcon(itemID: song.songID))
        }
        .labelStyle(ViewSongsStyleLabel())
        .id(song.songID)
    }
}

// MARK: - ViewSongsMenuButtons (view)

/// Menu is reachable via right-click and via menu button,
/// so in a seperaie View to avoid duplicating.
struct ViewSongsMenuButtons: View {
    let song: SongFields
    var body: some View {
        Button("Add this song to the queue") {
            KodiClient.shared.sendPlaylistAction(api: .playlistAdd, songList: [song.songID])
        }
    }
}

// MARK: - ViewSongsStyleLabel (label style)

struct ViewSongsStyleLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.foregroundColor(.accentColor)
            configuration.title
        }
    }
}
