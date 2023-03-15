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
    /// The optional selection
    @Binding var selection: BrowserModel.Selection

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    playSongs(shuffle: false)
                }, label: {
                    Label("Play songs", systemImage: "play.fill")
                })
                Button(action: {
                    playSongs(shuffle: true)
                }, label: {
                    Label("Shuffle songs", systemImage: "shuffle")
                })
            }
            .buttonStyle(ButtonStyles.Play())
            .padding(.top)
            /// On macOS, `List` is not lazy, so slow... So, viewed in a `LazyVStack` and no fancy swipes....
            ScrollView {
                LazyVStack {
                    ForEach(Array(songs.enumerated()), id: \.element) { index, song in
                        Song(song: song, album: selection.album)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background((index % 2 == 0) ? Color.gray.opacity(0.1) : Color.clear)
                            .cornerRadius(6)
                            .padding(.trailing)
                    }
                }
            }
        }
        .id(selection)
    }

    func playSongs(shuffle: Bool) {
        var media: KodioSettings.Crossfade = .playlist
        if let album = selection.album {
            media = album.compilation ? .compilation : .album
        }
        KodioSettings.setPlayerSettings(media: media)
        songs.play(shuffle: shuffle)
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
                    Text(song.displayArtist)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text(song.album)
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
        @ViewBuilder var icon: some View {
            if song.id == player.currentItem?.id && player.currentItem?.media == .song {
                Image(systemName: player.properties.speed == 0 ? "pause.fill" : "play.fill")
            } else {
                Image(systemName: song.userRating == 0 ? "music.note" : "heart")
            }
        }
        /// The art or track for the song item
        @ViewBuilder var art: some View {
            if album != nil {
                Text("\(song.track)")
                    .font(.headline)
            } else {
                KodiArt.Poster(item: song)
                    .cornerRadius(4)
                    .frame(width: 60, height: 60)
            }
        }
    }
}

extension SongsView {
    struct Actions: View {
        let song: Audio.Details.Song
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
            .tint(.green)
            Button(action: {
                Task {
                    await song.toggleFavorite()
                }
            }, label: {
                Label(song.userRating == 0 ? "Add song to favourites" : "Remove song from favourites",
                      systemImage: song.userRating == 0 ? "heart.fill" : "heart")
            })
            .tint(.red)
            Button(action: {
                Task {
                    await song.togglePlayedState()
                }
            }, label: {
                Label(song.playcount == 0 ? "Mark song as played" : "Mark song as new",
                      systemImage: song.playcount == 0 ? "speaker" : "speaker.slash")
            })
        }
    }
}
