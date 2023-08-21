//
//  MusicMatchModel.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

#if os(macOS)

import SwiftUI
import SwiftlyKodiAPI
import SwiftlyStructCache
import iTunesLibrary

/// The model for ``MusicMatchView``
final class MusicMatchModel: ObservableObject, @unchecked Sendable {
    /// The status of matching songs between Kodi and Music
    @Published var status: Status = .none
    /// Matching progress values
    @Published var progress: Progress = .init(total: 0, current: 0)
    /// Setting which ratings will be used
    @AppStorage("ratingAction")
    var ratingAction: MusicMatchModel.RatingAction = .useKodiRating
    /// Setting which playcount will be used
    @AppStorage("playcountAction")
    var playcountAction: MusicMatchModel.PlaycountAction = .useKodiPlaycount
    /// The items to match
    var musicMatchItems: [MusicMatchModel.Item] = []
    /// The optional cache of the Music Match
    var cache: [MusicMatchModel.Item]?
    /// The MusicBridge class
    let musicBridge = MusicBridge()

    // MARK: Get Kodi and Music songs

    /// Get all songs from Kodi
    private func getKodiSongs() async {
        logger("Loading Kodi Songs...")
        var items: [MusicMatchModel.Item] = []
        // for song in KodiConnector.shared.library.songs where song.albumID == 2 {
        for song in KodiConnector.shared.library.songs {
            /// Make a new item
            var item = MusicMatchModel.Item(
                id: song.songID,
                title: song.title,
                album: song.album,
                artist: song.displayArtist,
                track: song.track,
                kodi: .init(
                    playcount: song.playcount,
                    lastPlayed: song.lastPlayed.isEmpty ? "2000-01-01 00:00:00" : song.lastPlayed,
                    rating: song.userRating
                )
            )
            /// Add cache data, if available
            if let cache, let cacheItem = cache.first(where: { $0.id == song.songID }) {
                item.sync = cacheItem.sync
                item.matched = cacheItem.matched
            }
            items.append(item)
        }
        musicMatchItems = items
    }

    /// Get all songs from Music
    /// - Returns: All songs from the Music database
    private func getMusicSongs() -> [ITLibMediaItem] {
        logger("Loading Music songs...")
        let iTunesLibrary: ITLibrary

        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.1")
        } catch {
            return [ITLibMediaItem]()
        }
        let songs = iTunesLibrary.allMediaItems.filter { $0.mediaKind == .kindSong }
        return songs
    }

    // MARK: Match songs

    /// Match songs between Kodi and Music
    func matchSongs() async {
        logger("Matching your songs...")
        cache = []
        if let cache = try? Cache.get(
            key: "MusicMatchItems",
            as: [MusicMatchModel.Item].self,
            folder: KodiConnector.shared.host.ip
        ) {
            self.cache = cache
        }
        await getKodiSongs()
        setProgress(total: Double(musicMatchItems.count), current: 0)
        let musicSongs = getMusicSongs()
            .filter { ($0.rating != 0 && $0.isRatingComputed == false) || $0.playCount > 0 }
        for (index, item) in musicMatchItems.enumerated() {
            /// Get the song from Music
            if let musicSong = musicSongs.first(where: {
                $0.title == item.title &&
                $0.album.title == item.album &&
                $0.trackNumber == item.track
            }) {
                var lastPlayed = "2000-01-01 00:00:00"
                if let musicLastPlayed = musicSong.lastPlayedDate {
                    lastPlayed = Utils.kodiDateFromSwiftDate(musicLastPlayed)
                }
                musicMatchItems[index].music = .init(
                    playcount: musicSong.playCount,
                    lastPlayed: lastPlayed,
                    rating: musicSong.isRatingComputed ? 0 : musicSong.rating / 10
                )
            }
            setProgress(current: Double(index))
            musicMatchItems[index].sync = calculateSyncValues(item: musicMatchItems[index])
        }
        logger("Done!")
    }

    // MARK: Synchronise songs

    /// Sync all songs between Kodi and Music
    func syncAllSongs() async {
        let items = musicMatchItems.filter { $0.itemInSync == false }
        setProgress(total: Double(items.count), current: 0)
        var index: Double = 0
        for item in musicMatchItems where !item.itemInSync {
            index += 1
            setProgress(current: index)
            await syncSong(song: item)
        }
        await setMusicMatchCache()
        musicBridge.sendNotification(title: "Kodio", message: "All your songs are in sync")
    }

    /// Sync one song between Kodi and Music
    /// - Parameter item: The song to sync as ``MusicMatchModel/Item``
    func syncSong(song: MusicMatchModel.Item) async {
        if let index = musicMatchItems.firstIndex(where: { $0.id == song.id }) {
            if song.kodi != song.sync {
                /// Update Kodi Item
                if var kodiSong = KodiConnector.shared.library.songs.first(where: { $0.songID == song.id }) {
                    kodiSong.playcount = song.sync.playcount
                    kodiSong.lastPlayed = song.sync.lastPlayed
                    kodiSong.userRating = song.sync.rating
                    await AudioLibrary.setSongDetails(song: kodiSong)
                    musicMatchItems[index].kodi = musicMatchItems[index].sync
                }
            }
            if song.music != song.sync {
                /// Update Music Item
                musicBridge.setMusicSongValues(
                    songID: musicBridge.getMusicSongID(
                        title: song.title,
                        album: song.album,
                        track: song.track
                    ),
                    values: song.sync
                )
                musicMatchItems[index].music = musicMatchItems[index].sync
            }
            /// Mark the item as matched
            musicMatchItems[index].matched = true
        }
    }

    // MARK: Helpers

    /// Calculate the sync values
    /// - Parameter item: The Music Match Item
    /// - Returns: The sync values
    func calculateSyncValues(item: MusicMatchModel.Item) -> MusicMatchModel.Values {
        /// Default values
        var playcount: Int = 0
        var lastPlayed: String = "2000-01-01 00:00:00"
        let rating = calculateRatingValue(item: item)
        /// Switch on new and previous matches songs
        switch item.matched {
        case true:
            /// Calculate new playcount
            let kodiPlayed = item.kodi.playcount - item.sync.playcount
            let musicPlayed = item.music.playcount - item.sync.playcount
            playcount = item.sync.playcount + kodiPlayed + musicPlayed
            /// Take the latest 'last played' date
            lastPlayed = item.kodi.lastPlayed > item.music.lastPlayed ? item.kodi.lastPlayed : item.music.lastPlayed
        case false:
            /// The song is never matched before
            switch playcountAction {
            case .useKodiPlaycount:
                playcount = item.kodi.playcount
                lastPlayed = item.kodi.lastPlayed
            case .useMusicPlaycount:
                playcount = item.music.playcount
                lastPlayed = item.music.lastPlayed
            case .useHighestPlaycount:
                playcount = item.kodi.playcount > item.music.playcount ? item.kodi.playcount : item.music.playcount
                lastPlayed = item.kodi.lastPlayed > item.music.lastPlayed ? item.kodi.lastPlayed : item.music.lastPlayed
            case .useTotalPlaycount:
                playcount = item.kodi.playcount + item.music.playcount
                lastPlayed = item.kodi.lastPlayed > item.music.lastPlayed ? item.kodi.lastPlayed : item.music.lastPlayed
            }
        }
        return .init(playcount: playcount, lastPlayed: lastPlayed, rating: rating)
    }

    /// Calculate the sync rating
    /// - Parameter item: The Music Match Item
    /// - Returns: The rating
    private func calculateRatingValue(item: MusicMatchModel.Item) -> Int {
        switch ratingAction {
        case .useKodiRating:
            return item.kodi.rating
        case .useMusicRating:
            return item.music.rating
        case .useHighestRation:
            return item.kodi.rating > item.music.rating ? item.kodi.rating : item.music.rating
        }
    }

    /// Set the progress values for the ``MusicMatchView``
    /// - Parameters:
    ///   - total: The total items
    ///   - current: The current item
    func setProgress(total: Double? = nil, current: Double? = nil) {
        Task { @MainActor in
            if let total {
                progress.total = total
            }
            if let current {
                progress.current = current
            }
        }
    }

    /// Store the Match struct in cache
    func setMusicMatchCache() async {
        do {
            try Cache.set(key: "MusicMatchItems", object: musicMatchItems, folder: KodiConnector.shared.host.ip)
        } catch {
            print("Saving Music Match Items failed with error: \(error)")
        }
    }
}

#endif
