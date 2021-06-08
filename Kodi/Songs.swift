///
/// Songs.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - Songs related stuff  (KodiClient extension)

extension KodiClient {

    // MARK: SongLists (struct)

    /// The list of all song types
    struct SongLists {
        var all = [SongFields]()
        var recentlyPlayed = [SongFields]()
        var mostPlayed = [SongFields]()
        var random = [SongFields]()
    }

    // MARK: getSongs (function)

    /// get a list of all songs
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: An array of all albums

    func getSongs(reload: Bool) {
        self.library.songs = false
        if !reload, let songs = self.getCache(key: "MySongs", as: [SongFields].self) {
            self.songs.all = songs
            self.songs.random = Array(songs.shuffled().prefix(100))
            getLibraryDetails()
            self.library.songs = true
        } else {
            let request = AudioLibraryGetSongs()
            sendRequest(request: request) { [weak self] result in
                switch result {
                case .success(let result):
                    guard let results = result?.result.songs else {
                        return
                    }
                    do {
                        try self?.setCache(key: "MySongs", object: results)
                    } catch {
                        self?.log(#function, "Error saving MySongs")
                    }
                    self?.songs.random = Array(results.shuffled().prefix(100))
                    self?.songs.all = results
                    self?.getLibraryDetails()
                    /// Save the date of the last library scan in the cache
                    self?.getAudioLibraryLastUpdate(cache: true)
                    self?.library.songs = true
                case .failure(let error):
                    self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: songListID (variable)

    /// The SwiftUI list should have a unique ID for each list to speed-up the view
    var songListID: String {
        switch filter.songs {
        case .album:
            return "album-\(albums.selected?.albumID ?? 0)"
        case .artist:
            return "artist-\(artists.selected?.artistID ?? 0)"
        case .playlist:
            return playlists.title ?? "playlist"
        case .search:
            return search.searchID
        case .genre:
            return "genre-\(genres.selected?.genreID ?? 0)"
        default:
            return "songs-\(filter.songs.hashValue)"
        }
    }

    // MARK: songsFilter (variable)

    /// Filter the songs for the SwiftUI lists
    var songsFilter: [SongFields] {
        switch filter.songs {
        case .album:
            return songs.all.filter { $0.albumID == albums.selected?.albumID }
        case .artist:
            return songs.all.filter { $0.albumArtist.first == artists.selected?.artist }
                .sorted { $0.year == $1.year ? $0.track < $1.track : $0.year < $1.year }
        case .mostPlayed:
            return songs.mostPlayed
        case .recentlyPlayed:
            return songs.recentlyPlayed
        case .recentlyAdded:
            return Array(songs.all.sorted { $0.dateAdded > $1.dateAdded }.prefix(100))
        case .compilations:
            return songs.random
        case .genre:
            return songs.all.filter {$0.genre.first == genres.selected?.label}
        case .search:
            return songs.all.filter({self.search.text.isEmpty ? true :
                                        $0.search.localizedCaseInsensitiveContains(self.search.text)})
        case .playlist:
            return playlists.songs
        default:
            return songs.all
        }
    }

    // MARK: songlistHeader (variable)

    /// The header for the SwiftUI songlist view
    var songlistHeader: String {
        switch filter.songs {
        case .artist:
            return artists.selected?.artist ?? "Artist"
        case .album:
            return albums.selected?.title ?? "Album"
        case .genre:
            return genres.selected?.label ?? "Genre"
        case .playlist:
            return playlists.title ?? "Playlist"
        default:
            return filter.songs.rawValue
        }
    }

    // MARK: getSongListIcon (function)

    /// Get an icon for the row in a SwiftUI songlist
    /// - Parameter itemID: The ID of the song
    /// - Returns: A 'SF symbol' string that can be used for a SwiftUI image

    func getSongListIcon(itemID: Int) -> String {
        /// Standard icon
        var icon = "music.note"
        /// Overrule if needed
        if itemID == self.player.item.songID {
            if self.player.properties.speed == 0 {
                icon = "pause.fill"
            } else {
                icon = "play.fill"
            }
        }
        return icon
    }

    // MARK: getSongsSmartLists (function)

    /// Get a list of recently played and recently added songs
    func getSongsSmartLists() {
        let recent = AudioLibraryGetSongs(filter: .recentlyPlayed)
        sendRequest(request: recent) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.songs else {
                    return
                }
                self?.songs.recentlyPlayed = results
                self?.library.songsRecent = true
                self?.log(#function, "Recently played songs loaded")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
        let most = AudioLibraryGetSongs(filter: .mostPlayed)
        sendRequest(request: most) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.songs else {
                    return
                }
                self?.library.songsMost = true
                self?.log(#function, "Most played albums loaded")
                self?.songs.mostPlayed = results
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - AudioLibrary.GetSongs (API request)

/// Get a list of songs

struct AudioLibraryGetSongs: KodiRequest {
    /// Arguments
    var filter: FilterType = .none
    /// Method
    var api = KodiAPI.audioLibraryGetSongs
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        var params = Params()
        switch filter {
        case .recentlyPlayed:
            params.sort.method = SortFields.lastPlayed.string()
            params.sort.order = SortFields.descending.string()
            params.limits.end = 25
        case .mostPlayed:
            params.sort.method = SortFields.playCount.string()
            params.sort.order = SortFields.descending.string()
            params.limits.end = 25
        default:
            params.sort.method = SortFields.track.string()
            params.sort.order = SortFields.ascending.string()
        }
        return buildParams(method: method, params: params)
    }
    /// The request struct
    struct Params: Encodable {
        let properties = SongFields().properties
        var sort = Sort()
        struct Sort: Encodable {
            var method: String = ""
            var order: String = ""
        }
        var limits = Limits()
        struct Limits: Encodable {
            let start = 0
            var end = 100000
        }
    }
    /// The response struct
    // typealias response = Response
    struct Response: Decodable {
        let songs: [SongFields]
    }
}

// MARK: - SongFields (struct)

/// The fields for an song
/// - Note: "Requesting the genreid, artistid, albumartistid and/or sourceid fields will result in increased response times"
///         From the Wiki, so I don't do that
struct SongFields: Codable, Identifiable {
    /// The fields that we ask for
    var properties = ["title", "artist", "year", "playcount", "albumid", "albumartist", "track", "lastplayed", "album",
                      "thumbnail", "dateadded", "genre", "duration"]
    /// Make it indentifiable
    var id = UUID()
    /// The fields from above
    var album: String = ""
    var albumArtist: [String] = [""]
    var albumID: Int = 0
    var artist: [String] = ["Play your own music"]
    var dateAdded: String = ""
    var genre: [String] = [""]
    var lastPlayed: String = ""
    var playCount: Int = 0
    var songID: Int = 0
    var thumbnail: String = ""
    var title: String = "Kodio"
    var track: Int = 0
    var year: Int = 0
    var duration: Int = 0
    /// Computed stuff
    var search: String {
        return "\(artist) \(album) \(title)"
    }
    var playCountLabel: String {
        return (playCount == 0 ? "Never played" : playCount == 1 ? "Played 1 time" : "Played \(playCount) times")
    }
    var playlistID = -1
}

extension SongFields {
    enum CodingKeys: String, CodingKey {
        case album, artist, genre, thumbnail, title, track, year, duration
        case albumID = "albumid"
        case albumArtist = "albumartist"
        case dateAdded = "dateadded"
        case lastPlayed = "lastplayed"
        case playCount = "playcount"
        case songID = "songid"
    }
}
