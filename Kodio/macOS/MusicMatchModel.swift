//
//  MusicMatchModel.swift
//  Kodio
//
//  Created by Nick Berendsen on 02/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI
import iTunesLibrary

/// The model for ``MusicMatchView``
class MusicMatchModel: ObservableObject {
    /// All the songs
    @Published var songs: [SongItem] = []
    /// Playcounts
    var playcounts: [Playcount] = []
    /// The status of matching songs between Kodi and Music
    @Published var status: Status = .none
    /// The MusicBridge class
    let musicBridge = MusicBridge()
    /// Init the model
    init() {
        logger("INIT THE MODEL")
        self.songs = getKodiSongs()
        if let cache = Cache.get(key: "MusicMatch", as: [Playcount].self) {
            self.playcounts = cache
        }
    }
}

// MARK: Load and match the library

extension MusicMatchModel {
    
    /// Match songs between Kodi and Music
    func matchSongs() async {
        logger("Matching your songs...")
        let songs = await getMusicMatch()
        Task { @MainActor [songs] in
            logger("Matching done")
            self.songs = songs
        }
    }
    
    /// Get all songs from Kodi
    /// - Returns: All songs from the Kodi database
    private func getKodiSongs() -> [SongItem] {
        logger("Loading Kodi Songs...")
        var tracks = [SongItem]()
        for song in KodiConnector.shared.library.songs {
            tracks.append(SongItem(id: song.songID,
                                   title: song.title,
                                   album: song.album,
                                   artist: song.displayArtist,
                                   track: song.track,
                                   kodiPlaycount: song.playcount,
                                   kodiRating: song.userRating / 2,
                                   kodiLastPlayed: song.lastPlayed)
            )
        }
        return tracks
    }

    /// Get all songs from Music
    /// - Returns: All songs from the Music database
    private func getMusicSongs() -> [ITLibMediaItem] {
        logger("Loading Music songs...")
        let iTunesLibrary: ITLibrary
        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
        } catch {
            return [ITLibMediaItem]()
        }
        let songs = iTunesLibrary.allMediaItems
        return songs
    }
    
    /// Match Kodi songs with Music Songs
    /// - Returns: An updated tabel with mUsic data added
    private func getMusicMatch() async -> [SongItem] {
        /// Get a fresh list of Kodi songs
        let kodiSongs = getKodiSongs()
        var tracks = [SongItem]()
        let musicSongs = getMusicSongs().filter {  ($0.rating != 0 && $0.isRatingComputed == false) || $0.playCount > 0}
        for song in kodiSongs {
            /// Make it mutable
            var song = song
            /// Get the song from Music
            if let musicSong = musicSongs.first(where: {
                $0.title == song.title &&
                $0.album.title == song.album &&
                $0.trackNumber == song.track
            }) {
                song.musicPlaycount = musicSong.playCount
                song.musicRating = musicSong.isRatingComputed ? 0 : musicSong.rating / 20
                song.musicLastPlayed = dateToKodiString(date: musicSong.lastPlayedDate)
            }
            /// Update the playcount table if the song is known
            if !playcounts.isEmpty, let index = playcounts.firstIndex(where: {$0.id == song.id}) {
                playcounts[index].kodiPlayed = song.kodiPlaycount - playcounts[index].kodiPlaycount
                playcounts[index].musicPlayed = song.musicPlaycount - playcounts[index].musicPlaycount
                /// Set the sync status
                song.playcountInSync = playcounts[index].morePlayed == 0 ? true : false
            } else {
                playcounts.append(Playcount(id: song.id,
                                            musicPlaycount: song.musicPlaycount,
                                            kodiPlaycount: song.kodiPlaycount,
                                            musicPlayed: 0,
                                            kodiPlayed: 0,
                                            synced: false
                                            /// Note: for debugging:
                                            /// synced: song.musicPlaycount == song.kodiPlaycount ? true : false
                                           )
                )
            }
            tracks.append(song)
        }
        /// Store the playcount table
        await setPlaycountCache()
        /// Return the songs
        return tracks
    }
}

// MARK: Sync all songs

extension MusicMatchModel {
    
    /// Sync all songs that are not in sync yet
    func syncAllSongs(ratingAction: RatingAction) async {
        /// Get all songs where the ratings are not in sync
        let ratings = songs.filter { $0.ratingStatus == 0 }
        logger("Update \(ratings.count) ratings")
        for song in ratings {
            let update = await syncRating(song: song, ratingAction: ratingAction)
            updateSongItem(song: update)
        }
        /// Get all songs where the playcounts are not in sync
        let playcounts = songs.filter { $0.playcountInSync == false }
        logger("Update \(playcounts.count) playcounts")
        for song in playcounts {
            let update = await syncPlaycount(song: song)
            updateSongItem(song: update)
        }
        /// Store the match table
        await setPlaycountCache()
        musicBridge.sendNotification(title: "Kodio", message: "All your songs are in sync")
        /// Enable the buttons again
        Task { @MainActor in
            status = .musicMatched
        }
    }
}

// MARK: Update song item in the Table View

extension MusicMatchModel {

    /// Update the song in the SwiftUI Table View
    /// - Parameter song: The song as``SongItem``
    func updateSongItem(song: SongItem) {
        /// Update the UI
        Task { @MainActor in
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                songs[index] = song
            }
        }
    }
}

// MARK: Playcounts

extension MusicMatchModel {
    
    /// Sync a playcount
    /// - Parameter song: The song as``SongItem``
    func syncPlaycount(song: SongItem) async -> SongItem {
        /// Make it mutable
        var song = song
        /// Find it in the playcoun table
        if let index = playcounts.firstIndex(where: {$0.id == song.id}) {
            switch playcounts[index].synced {
            case true:
                if let kodiPlaycount = playcounts[index].addToKodi {
                    await setKodiPlaycount(song: song, playcount: kodiPlaycount)
                    song.kodiPlaycount = kodiPlaycount
                }
                if let musicPlaycount = playcounts[index].addToMusic {
                    await setMusicPlaycount(song: song, playcount: musicPlaycount)
                    song.musicPlaycount = musicPlaycount
                }
                /// Update the table
                playcounts[index] = Playcount(id: song.id,
                                              musicPlaycount: song.musicPlaycount,
                                              kodiPlaycount: song.kodiPlaycount,
                                              musicPlayed: 0,
                                              kodiPlayed: 0,
                                              synced: true
                )
            case false:
                /// Set the playcount for both as the total
                let playcount = playcounts[index].kodiPlaycount + playcounts[index].musicPlaycount
                song.kodiPlaycount = playcount
                song.musicPlaycount = playcount
                /// Update the table
                playcounts[index] = Playcount(id: song.id,
                                              musicPlaycount: playcount,
                                              kodiPlaycount: playcount,
                                              musicPlayed: 0,
                                              kodiPlayed: 0,
                                              synced: true
                )
                /// Update the songs
                await setKodiPlaycount(song: song, playcount: playcount)
                await setMusicPlaycount(song: song, playcount: playcount)
            }
        }
        /// Mark as synced
        song.playcountInSync = true
        song.kodiLastPlayed = song.lastPlayed
        song.musicLastPlayed = song.lastPlayed
        
        /// Return the song
        return song
    }
    
    /// Set a playcount in Kodi
    /// - Parameter song: The song as ``SongItem``
    func setKodiPlaycount(song: SongItem, playcount: Int) async {
        logger("Set Kodi Playcount to \(playcount)")
        /// Find the Kodi song in the database and update it
        if var kodiSong = KodiConnector.shared.library.songs.first(where: {$0.songID == song.id}) {
            kodiSong.playcount = playcount
            kodiSong.lastPlayed = song.lastPlayed
            await AudioLibrary.setSongDetails(song: kodiSong)
        }
    }
    
    /// Set a playcount in Music
    /// - Parameter song: The song as ``SongItem``
    func setMusicPlaycount(song: SongItem, playcount: Int) async {
        logger("Set Music Playcount to \(playcount)")
        /// Get the AppeScript ID for the song
        let songID = getMusicSongID(song: song)
        /// Update the playcount in Music
        musicBridge.setMusicSongPlaycount(songID: songID, playcount: playcount)
        if song.musicLastPlayed < song.lastPlayed {
            /// Update the last played date
            musicBridge.setMusicSongPlayDate(songID: songID, playDate: song.lastPlayed)
        }
    }
    
    /// Store the Match in cache
    func setPlaycountCache() async {
        do {
            try Cache.set(key: "MusicMatch", object: playcounts)
        } catch {
            print("Saving Music Match failed with error: \(error)")
        }
    }
}

// MARK: Ratings

extension MusicMatchModel {
    
    /// Sync a rating
    /// - Parameter song: The song from the ``SongItem``
    func syncRating(song: SongItem, ratingAction: RatingAction) async -> SongItem {
        var song = song
        if song.musicRating != song.kodiRating {
            logger("Update rating")
            switch ratingAction {
            case .useKodiRating:
                await setMusicRating(song: &song)
            case .useMusicRating:
                await setKodiRating(song: &song)
            case .useHighestRation:
                if song.musicRating < song.kodiRating {
                    await setMusicRating(song: &song)
                } else {
                    await setKodiRating(song: &song)
                }
            }
        }
        /// Return the updated song
        return song
    }
    
    /// Set a rating in Kodi
    /// - Parameter item: The song as a``SongItem``
    func setKodiRating(song: inout SongItem) async {
        /// Set the new Kodi rating for the song
        song.kodiRating = song.musicRating
        /// Find the Kodi song in the database and update it
        if var kodiSong = KodiConnector.shared.library.songs.first(where: {$0.songID == song.id}) {
            kodiSong.userRating = song.musicRating * 10
            await AudioLibrary.setSongDetails(song: kodiSong)
        }
    }
    
    /// Set a rating in Music
    /// - Parameter song: The song as a``SongItem``
    func setMusicRating(song: inout SongItem) async {
        /// Set the new Music rating for the song
        song.musicRating = song.kodiRating
        /// Get the AppeScript ID for the song
        let songID = getMusicSongID(song: song)
        /// Update the song in Music
        musicBridge.setMusicSongRating(songID: songID, rating: song.kodiRating * 20)
    }
}

// MARK: Helpers

extension MusicMatchModel {
    
    /// Get the AppeScript ID for the song
    /// - Parameter song: The son as a ``SongItem``
    /// - Returns: The Applescript ID of the song
    private func getMusicSongID(song: SongItem) -> Int {
        musicBridge.getMusicSongID(title: song.title,
                                   album: song.album,
                                   track: song.track
        )
    }
    
    private func dateToKodiString(date: Date?) -> String {
        var string = ""
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            string = dateFormatter.string(from: date)
        }
        return string
    }
}

// MARK: Struct and Enum extensions

extension MusicMatchModel {
    
    /// A song in the Table View
    struct SongItem: Identifiable, Codable {
        /// Make it indentifiable
        var id: Library.id
        /// The title of the song
        var title: String = ""
        /// The album title of the song
        var album: String = ""
        /// The artist of the song
        var artist: String = ""
        /// The track number of the song
        var track: Int = 0
        /// Playcount in Music
        var musicPlaycount: Int = 0
        /// Playcount in Kodi
        var kodiPlaycount: Int = 0
        /// Bool if the playcount is i sync
        var playcountInSync: Bool = false
        /// The song rating from Music
        var musicRating: Int = 0
        /// The song rating from Kodi
        var kodiRating: Int = 0
        /// The last played date in Music
        var musicLastPlayed: String = ""
        /// The last played date in Kodi
        var kodiLastPlayed: String = ""
        
        /// # Calculated stuff
        
        /// The status if the song rating is in sync or not
        /// - Note: Not a `Bool` because the SwiftUI `Table` does not like that
        var ratingStatus: Int {
            return musicRating == kodiRating ? 1 : 0
        }
        
        /// The status if a song is matched or not
        /// - Note: Not a `Bool` because the SwiftUI `Table` does not like that
        var matchStatus: Int {
            return (musicRating == kodiRating) && playcountInSync ? 1 : 0
        }
        
        /// Find the highest last plated date
        var lastPlayed: String {
            return kodiLastPlayed < musicLastPlayed ? musicLastPlayed : kodiLastPlayed
        }
        
        /// Get the color for the rating view
        /// - Parameters:
        ///   - ratingAction: The ``MusicMatchModel/RatingAction``
        ///   - player: The ``MusicMatchModel/PlayerType``
        /// - Returns: A SwiftUI Color
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
    
    struct Playcount: Codable {
        var id: Library.id = 0
        var musicPlaycount: Int = 0
        var kodiPlaycount: Int = 0
        var musicPlayed: Int = 0
        var kodiPlayed: Int = 0
        var synced = false
        
        /// # Calculated stuff
        
        var morePlayed: Int {
            musicPlayed + kodiPlayed
        }
        
        var addToKodi: Int? {
            musicPlayed != 0 ? kodiPlaycount + morePlayed : nil
        }
        
        var addToMusic: Int? {
            kodiPlayed != 0 ? musicPlaycount + morePlayed : nil
        }
    }
    
    /// The status of rating matching
    enum Status: String {
        /// Not loaded
        case none = "Loading songs from Kodi"
        /// Got ratings from Kodi
        case kodiLoaded = "Loaded songs from Kodi"
        /// Match the Kodi songs with music
        case musicMatching = "Matching songs with Music; this might take some time..."
        /// Kodi songs are matched with Music
        case musicMatched = "Matched songs with Music"
        /// Sync all ratings
        case syncAllRatings = "Syncing your songs"
    }
    
    /// Which rating to use for syncing
    enum RatingAction: String, CaseIterable {
        /// Use the ratings from Kodi
        case useKodiRating = "Use Kodi Ratings"
        /// Use the ratings from Music
        case useMusicRating = "Use Music Ratings"
        /// Use the highest rating
        case useHighestRation = "Use Highest Rating"
    }
    
    /// The type of player
    enum PlayerType {
        /// Kodi
        case kodi
        /// Music
        case music
    }
}
