//
//  ViewSyncRatings.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI
import iTunesLibrary

/// A View to sync ratings between Kodi and Music
struct ViewSyncRatings: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The MusicBridge class
    let musicBridge = MusicBridge()
    /// Setting wich ratings will be used
    @AppStorage("ratingAction") var ratingAction: RatingAction = .useKodiRating
    /// The status of matching songs between Kodi and Music
    @State var status: Status = .none
    /// The table with the songs
    @State var songTable: [SongTable] = []
    /// Sort order for the table
    @State var sortOrder: [KeyPathComparator<SongTable>] = [ .init(\.status, order: SortOrder.forward)]
    /// The View
    var body: some View {
        VStack(spacing: 0) {
            Table(sortOrder: $sortOrder) {
                TableColumn("Action", value: \.status) { song in
                    Button(action: {
                        Task {
                            await syncRating(item: song)
                        }
                    }, label: {
                        Text("Sync")
                            .foregroundColor(.accentColor)
                    })
                        .buttonStyle(.plain)
                        .disabled(song.status == 1 || status != .musicMatched)
                }
                .width(80)
                TableColumn("Title", value: \.song.title) { song in
                    Text(song.song.title)
                }
                TableColumn("Kodi Rating", value: \.kodiRating) { song in
                    ratings(rating: song.kodiRating)
                        .foregroundColor(song.color(ratingAction: ratingAction, player: .kodi))
                }
                TableColumn("Music Rating", value: \.musicRating) { song in
                    if status == .musicMatched || status == .syncAllRatings {
                        ratings(rating: song.musicRating)
                            .foregroundColor(song.color(ratingAction: ratingAction, player: .music))
                    } else {
                        Text("Unknown")
                    }
                }
            } rows: {
                ForEach(songTable.sorted(using: sortOrder)) { item in
                    TableRow(item)
                }
            }
            Text(status.rawValue)
                .font(.headline)
                .padding()
            Button(action: {
                status = .musicMatching
                Task {
                    async let songs = getMusicRatings()
                    songTable = await songs
                }
            }, label: {
                Text("Get ratings from Music")
            })
                .disabled(status == Status.musicMatching)
            HStack {
                Picker("Synchronise:", selection: $ratingAction) {
                    ForEach(RatingAction.allCases) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .frame(width: 240)
                Button(action: {
                    /// Disable the buttons
                    status = .syncAllRatings
                    Task {
                        await syncAllRatings()
                    }
                }, label: {
                    Text("Sync your ratings")
                })
            }
            .padding()
            .disabled(status != Status.musicMatched)
        }
        .disabled(status == Status.syncAllRatings)
        .task {
            async let songs = getKodiSongs()
            songTable = await songs
        }
    }

    /// View the song rating with stars
    /// - Parameters:
    ///   - rating: The rating
    /// - Returns: A view with stars
    @ViewBuilder func ratings(rating: Int) -> some View {
        HStack {
            ForEach(1..<6, id: \.self) { number in
                Image(systemName: number <= rating ? "star.fill" : "star")
                    .font(.caption)
            }
        }
    }
}

extension ViewSyncRatings {

    /// Get all songs from Kodi
    /// - Returns: All songs from the Kodi database
    func getKodiSongs() async -> [SongTable] {
        var tracks = [SongTable]()
        for song in library.songs.all {
            var track = SongTable()
            track.song = song
            tracks.append(track)
        }
        Task { @MainActor in
            status = .kodiLoaded
        }
        return tracks
    }

    /// Get all songs from Music
    /// - Returns: All songs from the Music database
    func getMusicSongs() -> [ITLibMediaItem] {
        logger("Getting Music songs...")
        let iTunesLibrary: ITLibrary
        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
        } catch {
            logger("Can't get the songs from Music")
            return [ITLibMediaItem]()
        }
        let songs = iTunesLibrary.allMediaItems
        logger("Found \(songs.count) songs")
        return songs
    }
    
    /// Get all ratings from Music songs
    /// - Returns: A new song table with Music ratings added
    func getMusicRatings() async -> [SongTable] {
        /// The songs in the table
        var songs = songTable
        /// Get the songs from Music and filter by rated songs only
        let musicSongs = getMusicSongs().filter { $0.rating != 0 && $0.isRatingComputed == false}
        for musicSong in musicSongs {
            if let index = songs.firstIndex(where: {
                $0.song.title == musicSong.title  &&
                $0.song.album == musicSong.album.title &&
                $0.song.track == musicSong.trackNumber
            }) {
                songs[index].musicRating = musicSong.rating / 20
            }
        }
        Task { @MainActor in
            status = .musicMatched
        }
        return songs
    }
}

extension ViewSyncRatings {
    
    /// Sync all ratings that are not in sync yet
    func syncAllRatings() async {
        /// Ignore 'AudioLibrary.OnUpdate' notifications or else it is too much for Kodio and it will crash
        KodiClient.shared.scanningLibrary = true
        /// Get all songs that are not in sync
        let songList = songTable.filter { $0.status == 0 }
        for song in songList {
            await syncRating(item: song)
        }
        /// Let it settle for a moment or else we still get notfications
        try! await Task.sleep(nanoseconds: 5_000_000_000)
        /// Update the Library
        await Library.shared.getLastUpdate()
        /// Update the UI
        await library.selectLibraryList(libraryList: library.libraryLists.selected, reset: false)
        /// Enable 'AudioLibrary.OnUpdate' notifications again
        KodiClient.shared.scanningLibrary = false
        musicBridge.sendNotification(title: "Kodio", message: "All your ratings are in sync")
        /// Enable the buttons again
        Task { @MainActor in
            status = .musicMatched
        }
    }
    
    /// Sync a rating
    /// - Parameter song: The song from the ``SongTable``
    func syncRating(item: SongTable) async {
        switch ratingAction {
        case .useKodiRating:
            await setMusicRating(item: item)
        case .useMusicRating:
            await setKodiRating(item: item)
        case .useHighestRation:
            if item.musicRating < item.kodiRating {
                await setMusicRating(item: item)
            } else {
                await setKodiRating(item: item)
            }
        }
    }
    
    /// Set a rating in Kodi
    /// - Parameter item: The song from the ``SongTable``
    func setKodiRating(item: SongTable) async {
        /// Get a song a change its rating
        var song = item.song
        song.rating = item.musicRating * 2
        await Library.shared.setSongDetails(song: song)
        /// Update the UI
        Task { @MainActor in
            if let index = songTable.firstIndex(where: { $0.song.songID == item.song.songID }) {
                songTable[index].song.rating = item.musicRating * 2
            }
        }
    }
    
    /// Set a rating in Music
    /// - Parameter item: The song from the ``SongTable``
    func setMusicRating(item: SongTable) async {
        /// Get the AppeScript ID for the song
        let songID = musicBridge.getMusicSongID(title: item.song.title,
                                                 album: item.song.album,
                                                 track: item.song.track
        )
        musicBridge.setMusicSongRating(songID: songID, rating: item.song.rating * 10)
        Task { @MainActor in
            /// Update the UI
            if let index = songTable.firstIndex(where: { $0.song.songID == item.song.songID }) {
                songTable[index].musicRating = item.kodiRating
            }
        }
    }
}

extension ViewSyncRatings {
    
    /// Which rating to use for syncing
    enum RatingAction: String, Identifiable, CaseIterable {
        /// Use the ratings from Kodi
        case useKodiRating = "Use Kodi Ratings"
        /// Use the ratings from Music
        case useMusicRating = "Use Music Ratings"
        /// Use the highest rating
        case useHighestRation = "Use Highest Rating"
        /// Make it indentifiable
        var id: String { self.rawValue }
    }

    /// The type of player
    enum PlayerType {
        /// Kodi
        case kodi
        /// Music
        case music
    }
    
    /// The status of rating matching
    enum Status: String {
        /// Not loaded
        case none = "Getting Kodi songs ratings"
        /// Got ratings from Kodi
        case kodiLoaded = "Got song ratings from Kodi"
        /// Match the Kodi songs with music
        case musicMatching = "Matching Kodi songs with Music; this might take some time..."
        /// Kodi songs are matched with Music
        case musicMatched = "Matched Kodi songs with Music"
        /// Sync all ratings
        case syncAllRatings = "Syncing your ratings"
    }
    
    /// A song in the Table View
    struct SongTable: Identifiable {
        /// Make it indentifiable
        var id = UUID().uuidString
        /// The status if the song rating is in sync or not
        /// - Note: Not a ``Bool`` because the SwiftUI ``Table`` does not like that
        var status: Int {
            return musicRating == kodiRating ? 1 : 0
        }
        /// The Kodi song struct
        var song = Library.SongItem()
        /// The song rating from Music
        /// - Note: Music rating goes from 0 to 100; it will be divided by 20 on load so it goes to 0 to 5
        var musicRating: Int = 0
        /// The song rating from Kodi
        /// - Note: Kodi rating goes from 0 to 10; it will be divided by 2 here so it goes to 0 to 5
        var kodiRating: Int {
            return song.rating / 2
        }
        /// Get the color for the rating view
        /// - Parameters:
        ///   - ratingAction: The ``RatingAction``
        ///   - player: The ``PlayerType``
        /// - Returns: A SwiftUI ``Color``
        func color(ratingAction: RatingAction, player: PlayerType) -> Color {
            switch player {
            case .kodi:
                switch ratingAction {
                case .useKodiRating:
                    return musicRating == kodiRating ? .primary : .green
                case .useMusicRating:
                    return musicRating != kodiRating ? .red : .primary
                case .useHighestRation:
                    return musicRating > kodiRating ? .red : musicRating < kodiRating ? .green : .primary
                }
            case .music:
                switch ratingAction {
                case .useKodiRating:
                    return musicRating != kodiRating ? .red : .primary
                case .useMusicRating:
                    return musicRating == kodiRating ? .primary : .green
                case .useHighestRation:
                    return musicRating < kodiRating ? .red : musicRating > kodiRating ? .green : .primary
                }
            }
        }
    }
}
