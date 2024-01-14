//
//  SongView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for a single song
struct SongView: View {
    /// The KodiConnector model
    @Environment(KodiConnector.self)
    private var kodi
    /// The song to view
    let song: Audio.Details.Song
    /// The optional selected album
    let album: Audio.Details.Album?
    /// The body of the `View`
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
                actions
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .frame(width: 40)
            .menuStyle(.borderlessButton)
        }
        .padding()
        .contextMenu {
            actions
        }
#if os(visionOS)
        .hoverEffect()
#endif
    }
    /// The icon for the song item
    var icon: some View {
        VStack {
            if song.id == kodi.player.currentItem?.id && kodi.player.currentItem?.media == .song {
                Image(systemName: kodi.player.properties.speed == 0 ? "pause.fill" : "play.fill")
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
    @ViewBuilder var art: some View {
        ZStack {
            Text("\(song.track)")
                .font(.headline)
                .opacity(album == nil ? 0 : 1)
            KodiArt.Poster(item: song)
                .opacity(album == nil ? 1 : 0)
        }
        .cornerRadius(4)
    }
}

extension SongView {

    /// The actions for the song
    @ViewBuilder var actions: some View {
        Button(action: {
            song.play(host: kodi.host)
        }, label: {
            Label("Play song", systemImage: "play")
        })
        Menu {
            if song.userRating > 0 {
                Button(action: {
                    Task {
                        await song.setUserRating(host: kodi.host, rating: 0)
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
                        await song.setUserRating(host: kodi.host, rating: value)
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
                await song.togglePlayedState(host: kodi.host)
            }
        }, label: {
            Label(
                song.playcount == 0 ? "Mark song as played" : "Mark song as new",
                systemImage: song.playcount == 0 ? "speaker" : "speaker.slash"
            )
        })
    }
}
