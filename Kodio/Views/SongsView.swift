//
//  DetailsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Songs View
struct SongsView: View {
    /// The songs for this View
    let songs: [Audio.Details.Song]
    /// The optional selected album
    let selectedAlbum: Audio.Details.Album?
    /// The body of the View
    var body: some View {
        /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    /// Scroll to the top on new selection
                    Divider()
                        .id("SongList")
                        .hidden()
                    ForEach(Array(songs.enumerated()), id: \.element) { index, song in
                        Song(song: song, album: selectedAlbum)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                            .padding(.trailing)
                    }
                    .task(id: songs) {
                        proxy.scrollTo("SongList", anchor: .top)
                    }
                }
            }
            .padding(.leading)
        }
    }
}

extension SongsView {

    /// The View for a song
    struct Song: View {
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        /// The song tho view
        let song: Audio.Details.Song
        /// The optional selected album
        let album: Audio.Details.Album?
        var body: some View {
            HStack {
                icon
                    .frame(width: 20)
                art
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text(song.title)
                    Text(song.subtitle)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text(song.details)
                        .font(.caption)
                        .opacity(0.6)
                }
                Spacer()
                Menu {
                    Actions(song: song)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .frame(width: 40)
                .menuStyle(.borderlessButton)
            }
            .padding()
            .contextMenu {
                Actions(song: song)
            }
        }
        /// The icon for the song item
        var icon: some View {
            VStack {
                if song.id == player.currentItem?.id && player.currentItem?.media == .song {
                    Image(systemName: player.properties.speed == 0 ? "pause.fill" : "play.fill")
                } else {
                    Image(systemName: song.userRating == 0 ? "music.note" : "heart")
                    if song.userRating > 0 {
                        Text("\(song.userRating)")
                            .font(.caption)
                    }
                }
            }
        }
        /// The art or track for the song item
        var art: some View {
            ZStack {
                Text("\(song.track)")
                    .font(.headline)
                    .opacity(album == nil ? 0 : 1)
                KodiArt.Poster(item: song)
                    .opacity(album == nil ? 1 : 0)
            }
            .cornerRadius(4)
            .frame(width: 60, height: 60)
        }
    }
}

extension SongsView {

    /// A SwiftUI View with action for a Song
    struct Actions: View {
        /// The Song
        let song: Audio.Details.Song
        /// The body of the View
        var body: some View {
            Button(action: {
                /// Check if this song is in the current playlist
                /// and if not, set the Player Settings to 'playlist'
                if song.playlistID == nil {
                    KodioSettings.setPlayerSettings(media: .playlist)
                }
                song.play()
            }, label: {
                Label("Play song", systemImage: "play")
            })
            Menu {
                if song.userRating > 0 {
                    Button(action: {
                        Task {
                            await song.setUserRating(rating: 0)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "star.slash")
                            Text("Remove your rating")
                        }
                    })
                }
                ForEach((1...10).reversed(), id: \.self) { value in
                    Button(action: {
                        Task {
                            await song.setUserRating(rating: value)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: song.userRating == value ? "star.fill" : "\(value).circle.fill")
                            Text("Rate with \(value)")
                        }
                    })
                    .disabled(song.userRating == value)
                }
            } label: {
                Text("Rate your song")
            }
            Button(action: {
                Task {
                    await song.togglePlayedState()
                }
            }, label: {
                Label(
                    song.playcount == 0 ? "Mark song as played" : "Mark song as new",
                    systemImage: song.playcount == 0 ? "speaker" : "speaker.slash"
                )
            })
        }
    }
}
