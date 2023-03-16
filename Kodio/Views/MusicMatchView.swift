//
//  MusicMatchView.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI
import iTunesLibrary
import SwiftlyKodiAPI

/// The View to sync ratings and playcounts between Kodi and Music
struct MusicMatchView: View {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The MusicMatch model
    @StateObject var musicMatch = MusicMatchModel()
    /// Setting wich ratings will be used
    @AppStorage("ratingAction") var ratingAction: MusicMatchModel.RatingAction = .useKodiRating
    /// The songs in the table
    @State private var songs: [MusicMatchModel.SongItem] = []
    /// Sort order for the table
    @State var sortOrder: [KeyPathComparator<MusicMatchModel.SongItem>] = [ .init(\.lastPlayed, order: SortOrder.reverse)]
    /// The body of the `View`
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Music Match")
                    .font(.title)
                Text("Match ratings and playcounts between Kodi and Music")
                    .font(.subheadline)
            }
            .modifier(PartsView.ListHeader())
            Table(sortOrder: $sortOrder) {
                TableColumn("Action", value: \.lastPlayed) { song in
                    Button(action: {
                        Task {
                            var song = await musicMatch.syncRating(song: song, ratingAction: ratingAction)
                            song = await musicMatch.syncPlaycount(song: song)
                            musicMatch.updateSongItem(song: song)
                            songs = musicMatch.songs
                            /// Store the playcount table
                            await musicMatch.setPlaycountCache()
                        }
                    }, label: {
                        Text("Sync")
                            .foregroundColor(.accentColor)
                    })
                    .buttonStyle(.plain)
                    .disabled(song.matchStatus == 1)
                    .disabled(musicMatch.status != .musicMatched)
                }
                .width(80)
                TableColumn("Title", value: \.title)
                TableColumn("Artist", value: \.artist)
                TableColumn("Playcount", value: \.kodiPlaycount) { song in
                    playcount(song: song)
                }
                TableColumn("Kodi Rating", value: \.kodiRating) { song in
                    ratings(rating: song.kodiRating)
                        .foregroundColor(song.color(ratingAction: ratingAction, player: .kodi))
                }
                TableColumn("Music Rating", value: \.musicRating) { song in
                    if musicMatch.status == .musicMatched || musicMatch.status == .syncAllSongs {
                        ratings(rating: song.musicRating)
                            .foregroundColor(song.color(ratingAction: ratingAction, player: .music))
                    } else {
                        Text("Unknown")
                    }
                }
            } rows: {
                ForEach(songs.sorted(using: sortOrder)) { item in
                    TableRow(item)
                }
            }
            VStack {
                statusMessage(status: musicMatch.status)
                Button(action: {
                    musicMatch.status = .musicMatching
                    Task {
                        await musicMatch.matchSongs()
                        songs = musicMatch.songs
                        musicMatch.status = .musicMatched
                    }
                }, label: {
                    Text(musicMatch.status == .musicMatched ? "Match songs again" : "Match songs")
                })
                .disabled(musicMatch.status == .musicMatching)
                HStack {
                    Picker("Ratings:", selection: $ratingAction) {
                        ForEach(MusicMatchModel.RatingAction.allCases, id: \.self) { action in
                            Text(action.rawValue).tag(action)
                        }
                    }
                    .frame(width: 240)
                    Button(action: {
                        /// Disable the buttons
                        musicMatch.status = .syncAllSongs
                        Task {
                            /// Sync all songs
                            await musicMatch.syncAllSongs(ratingAction: ratingAction)
                            /// Get the new list
                            songs = musicMatch.songs
                            /// Enable the buttons again
                            musicMatch.status = .musicMatched
                        }
                    }, label: {
                        Text("Sync your songs")
                    })
                }
                .padding()
                .disabled(musicMatch.status != .musicMatched)
            }
        }
        .disabled(musicMatch.status == .syncAllSongs)
        .animation(.default, value: musicMatch.status)
    }
}

// MARK: SwiftUI extensions

extension MusicMatchView {

    /// View the song rating with stars
    /// - Parameters:
    ///   - rating: The rating
    /// - Returns: A view with stars
    func ratings(rating: Int) -> some View {
        return HStack(spacing: 0) {
            ForEach(1..<6, id: \.self) { number in
                Image(systemName: image(number: number))
                    .font(.caption)
            }
        }
        func image(number: Int) -> String {
            if number * 2 <= rating {
                return "star.fill"
            } else if number * 2 == rating + 1 {
                return "star.leadinghalf.filled"
            } else {
                return "star"
            }
        }
    }

    /// View the playcount
    /// - Parameter song: The ``MusicMatchModel/SongItem``
    /// - Returns: A View with playcount status
    @ViewBuilder func playcount(song: MusicMatchModel.SongItem) -> some View {

        if let playcount = musicMatch.playcounts.first(where: {$0.id == song.id}) {
            HStack {
                Image(systemName: playcount.synced ? "infinity" : "minus")
                Text("Kodi: \(song.kodiPlaycount)")
                if musicMatch.status == .musicMatched || musicMatch.status == .syncAllSongs {
                    Text("Music: \(song.musicPlaycount)")
                }
            }
            .foregroundColor(song.playcountInSync ? .primary : .red)
        } else {
            Text("Kodi: \(song.kodiPlaycount)")
        }
    }

    @ViewBuilder func statusMessage(status: MusicMatchModel.Status) -> some View {
        HStack {
            switch status {
            case .musicMatching, .syncAllSongs:
                ProgressView()
                    .scaleEffect(0.5)
                Text(status.rawValue)
            default:
                Text(status.rawValue)
            }
        }
        .frame(height: 30)
        .font(.headline)
    }
}
