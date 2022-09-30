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
    
    /// The AppState model
    @EnvironmentObject var appState: AppState
    
    /// The browser model
    @EnvironmentObject var browser: BrowserModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    KodioSettings.setPlayerSettings(setting: browser.selection.album == nil ? .track : .album)
                    browser.items.songs.play()
                }, label: {
                    Label("Play songs", systemImage: "play.fill")
                })
                Button(action: {
                    KodioSettings.setPlayerSettings(setting: browser.selection.album == nil ? .track : .album)
                    browser.items.songs.play(shuffle: true)
                }, label: {
                    Label("Shuffle songs", systemImage: "shuffle")
                })
            }
            .buttonStyle(ButtonStyles.Play())
            .padding(.top)
            List {
                ForEach(browser.items.songs) { song in
                    Song(song: song, album: browser.selection.album)
                }
            }
            .listStyle(.plain)
            .id(UUID())
        }
        .id(browser.selection)
    }
}

extension SongsView {
    
    /// The View for a song
    struct Song: View {
        /// The SceneState model
        @EnvironmentObject var scene: SceneState
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        /// The song tho view
        let song: Audio.Details.Song
        /// The optional selected album
        let album: Audio.Details.Album?
        var body: some View {
            HStack {
                icon
                if album != nil {
                    Text("\(song.track)")
                        .font(.headline)
                } else {
                    KodiArt.Poster(item: song)
                        .cornerRadius(4)
                        .frame(width: 60, height: 60)
                }
                VStack(alignment: .leading) {
                    Text(song.title)
                    Text(song.displayArtist)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text(song.album)
                        .font(.caption)
                        .opacity(0.6)
                }
            }
            .listRowSeparator(.visible)
            .swipeActions(edge: .leading) {
                Button(action: {
                    /// Check if this song is in the current playlist
                    /// and if not, set the Player Settings to 'track'
                    if song.playlistID == nil {
                        KodioSettings.setPlayerSettings(setting: .track)
                    }
                    song.play()
                }, label: {
                    Label("Play", systemImage: "play")
                    
                })
                .tint(.green)
                Button(action: {
                    Task {
                        await song.toggleFavorite()
                    }
                }, label: {
                    Label(song.userRating == 0 ? "Favorite" : "Unfavorite", systemImage: song.userRating == 0 ? "heart.fill" : "heart")
                })
                .tint(.red)
                Button(action: {
                    Task {
                        await song.togglePlayedState()
                    }
                }, label: {
                    Label(song.playcount == 0 ? "Mark played" : "Mark new", systemImage: song.playcount == 0 ? "speaker" : "speaker.slash")
                    
                })
            }
            #if os(macOS)
            .padding(.vertical)
            #endif
        }
        /// The icon for the song item
        @ViewBuilder var icon: some View {
            if song.id == player.currentItem?.id && player.currentItem?.media == .song {
                if player.properties.speed == 0 {
                    Image(systemName: "pause.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            } else {
                Image(systemName: song.userRating == 0 ? "music.note" : "heart")
            }
        }
    }
}
