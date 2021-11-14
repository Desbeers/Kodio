//
//  LibrarySongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Songs
    
    /// A struct will all song related items
    struct Songs {
        /// All songs in the library
        var all: [SongItem] = []
        /// A list containing random songs
        var random: [SongItem] = []
        /// A list containing songs that are never played
        var neverPlayed: [SongItem] = []
        /// A list containng the most played songs
        var mostPlayed: [SongItem] = []
        /// A list containng gecently played songs
        var recentlyPlayed: [SongItem] = []
        /// A song list ID for the SwiftUI List to speed-up rendering
        var listID = UUID().uuidString
    }
    
    /// Get all songs from the Kodi host
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True when loaded; else false
    func getSongs(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MySongs", as: [SongItem].self) {
            songs.all = result
            return true
        } else {
            let request = AudioLibraryGetSongs()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                songs.all = result.songs
                /// Add some album fields to the songs
                mergeSongsAndAlbums()
                /// Save in the cache
                try Cache.set(key: "MySongs", object: songs.all)
                /// Save the date of the last library scan in the cache
                await getLastUpdate(cache: true)
                return true
            } catch {
                print("Loading songs failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Add some fields from the album to the song
    private func mergeSongsAndAlbums() {
        for (index, song) in songs.all.enumerated() {
            if let album = albums.all.first(where: { $0.albumID == song.albumID }) {
                /// I like to know if the song is part of a compilation
                /// and there is no property for that
                songs.all[index].compilation = album.compilation
                /// Sometimes a song has a different thumbnail than the album
                /// so you end-up with many, many items in the cache
                songs.all[index].thumbnail = album.thumbnail
                /// Try to save on expensive queries
                songs.all[index].albumArtist = album.artist
                songs.all[index].albumArtistID = album.artistID
                /// Create the search string
                songs.all[index].searchString = "\(songs.all[index].artist.first ?? "") \(songs.all[index].album) \(songs.all[index].title)"
            }
        }
    }
    
    /// Get the songs from the database to add to the queue list
    /// - Returns: An array of song items
    func getSongsFromQueue() -> [Library.SongItem] {
        var songList: [Library.SongItem] = []
        let allSongs = Library.shared.songs.all
        for (index, song) in Queue.shared.queueItems.enumerated() {
            if var item = allSongs.first(where: { $0.songID == song.songID }) {
                item.queueID = index
                songList.append(item)
            }
        }
        return songList
    }
    
    /// Like or dislike a song
    func favoriteSongToggle(song: SongItem) {
        if let index = songs.all.firstIndex(where: { $0.songID == song.songID }),
           let list = filteredContent.songs.firstIndex(where: { $0.songID == song.songID }) {
            if song.rating == 0 {
                songs.all[index].rating = 10
                filteredContent.songs[list].rating = 10
            } else {
                songs.all[index].rating = 0
                filteredContent.songs[list].rating = 0
            }
            /// Save it on the host
            setSongDetails(song: songs.all[index])
            /// Save in the cache
            do {
                try Cache.set(key: "MySongs", object: songs.all)
            } catch {
                logger("Error saving MySongs")
            }
            /// Refresh UI
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        }
    }
    
    /// Save the song details in the database
    private func setSongDetails(song: SongItem) {
        let message = AudioLibrarySetSongDetails(song: song)
        kodiClient.sendMessage(message: message)
    }
    
    /// Retrieve all songs (Kodi API)
    struct AudioLibraryGetSongs: KodiAPI {
        /// Method
        var method = Method.audioLibraryGetSongs
        /// The JSON creator
        var parameters: Data {
            /// The parameters we ask for
            var params = Params()
            params.sort.method = SortMethod.artist.string()
            params.sort.order = SortMethod.ascending.string()
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The properties that we ask from Kodi
            let properties = ["title", "artist", "artistid", "year", "playcount", "albumid",
                              "track", "disc", "lastplayed", "album", "genreid",
                              "dateadded", "genre", "duration", "userrating"]
            /// The sort order
            var sort = SortFields()
        }
        /// The response struct
        struct Response: Decodable {
            /// The list of songs
            let songs: [SongItem]
        }
    }
    
    /// Retrieve filtered songs by ID (Kodi API)
    struct AudioLibraryGetSongIDs: KodiAPI {
        /// Arguments
        var media: MediaType = .song
        /// Method
        var method = Method.audioLibraryGetSongs
        /// The JSON creator
        var parameters: Data {
            /// The parameters we ask for
            var params = Params()
            switch media {
            case .recentlyPlayed:
                params.sort.method = SortMethod.lastPlayed.string()
                params.sort.order = SortMethod.descending.string()
            case .mostPlayed:
                params.sort.method = SortMethod.playCount.string()
                params.sort.order = SortMethod.descending.string()
            default:
                params.sort.method = SortMethod.track.string()
                params.sort.order = SortMethod.ascending.string()
            }
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// Sort order
            var sort = SortFields()
            /// Limits for the result
            let limits = Limits()
            /// The limits struct
            struct Limits: Encodable {
                /// Start limit
                let start = 0
                /// End limit
                let end = 50
            }
        }
        /// The response struct
        struct Response: Decodable {
            /// The list of songs
            let songs: [SongIdItem]
        }
    }
    
    /// Update the given song with the given details (Kodi API)
    struct AudioLibrarySetSongDetails: KodiAPI {
        /// Arguments
        var song: SongItem
        /// Method
        var method = Method.audioLibrarySetSongDetails
        /// The JSON creator
        var parameters: Data {
            /// The parameters
            var params = Params()
            params.songid = song.songID
            params.userrating = song.rating
            return buildParams(params: params)
        }
        /// The request struct
        /// - Note: The properties we want to set
        struct Params: Encodable {
            /// The song ID
            var songid: Int = 0
            /// The rating of the song
            var userrating: Int = 0
        }
        /// The response struct
        struct Response: Decodable { }
    }
    
    /// The struct for a song item
    struct SongItem: LibraryItem, Identifiable, Hashable {
        /// Make it indentifiable
        var id = UUID().uuidString
        /// The media type
        let media: MediaType = .song
        /// The SF symbol for this media item
        let icon: String = "music.note"
        /// Name of the album
        var album: String = ""
        /// ID of the album
        var albumID: Int = 0
        /// Array of Album Artists
        var albumArtist: [String] = []
        /// Array of Album ArtistsIDs
        var albumArtistID: [Int] = []
        /// Array of Artists
        var artist: [String] = []
        /// Array of ArtistID's
        var artistID: [Int] = []
        /// The date this song was added
        var dateAdded: String = ""
        /// An array with song genres
        var genre: [String] = []
        /// An array of song genre ID's
        var genreID: [Int] = []
        /// Date of last played
        var lastPlayed: String = ""
        /// Play count of the song
        var playCount: Int = 0
        /// The song ID
        var songID: Int = 0
        /// Rating of the song
        var rating: Int = 0
        /// Thumbnail of the song
        var thumbnail: String = ""
        /// Title of the song
        var title: String = ""
        /// Disk number of the song
        var disc: Int = 0
        /// Track number of the song
        var track: Int = 0
        /// Year of the song
        var year: Int = 0
        /// Duration of the song
        var duration: Int = 0
        /// Part of a compilation?
        /// - Note: Not a Kodi property, so manualy added
        var compilation: Bool = false
        /// This is for the player queue and its not a 'property'
        var queueID = -1
        /// Search string; will be filled-in later
        var searchString: String = ""
        /// Subtitle of the song
        var subtitle: String {
            return artist.joined(separator: " & ")
        }
        /// Details for the song
        var details: String {
            return album
        }
        /// Description of the song
        var description: String = ""
        /// Artists for this song
        var artists: String {
            return artist.joined(separator: " & ")
        }
        /// Fanart of the song
        /// - Note: Not needed, but required by protocol
        let fanart: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case album, artist, genre, thumbnail, title, track, disc, year, duration, compilation, searchString
            /// lowerCamelCase
            case albumID = "albumid"
            /// lowerCamelCase
            case artistID = "artistid"
            /// lowerCamelCase
            case albumArtist = "albumartist"
            /// lowerCamelCase
            case albumArtistID = "albumartistid"
            /// lowerCamelCase
            case dateAdded = "dateadded"
            /// lowerCamelCase
            case genreID = "genreid"
            /// lowerCamelCase
            case lastPlayed = "lastplayed"
            /// lowerCamelCase
            case playCount = "playcount"
            /// lowerCamelCase
            case songID = "songid"
            /// lowerCamelCase
            case rating = "userrating"
        }
        /// Custom init because fields from albums will be merged and without below
        /// we can't save/load the struct to/from the cache.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            album = try container.decodeIfPresent(String.self, forKey: .album) ?? ""
            albumID = try container.decodeIfPresent(Int.self, forKey: .albumID) ?? 0
            albumArtist = try container.decodeIfPresent([String].self, forKey: .albumArtist) ?? [""]
            albumArtistID = try container.decodeIfPresent([Int].self, forKey: .albumArtistID) ?? []
            artist = try container.decodeIfPresent([String].self, forKey: .artist) ?? ["Play your own music"]
            artistID = try container.decodeIfPresent([Int].self, forKey: .artistID) ?? []
            dateAdded = try container.decodeIfPresent(String.self, forKey: .dateAdded) ?? ""
            genre = try container.decodeIfPresent([String].self, forKey: .genre) ?? [""]
            genreID = try container.decodeIfPresent([Int].self, forKey: .genreID) ?? []
            lastPlayed = try container.decodeIfPresent(String.self, forKey: .lastPlayed) ?? ""
            playCount = try container.decodeIfPresent(Int.self, forKey: .playCount) ?? 0
            songID = try container.decodeIfPresent(Int.self, forKey: .songID) ?? 0
            disc = try container.decodeIfPresent(Int.self, forKey: .disc) ?? 0
            rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
            thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail) ?? ""
            searchString = try container.decodeIfPresent(String.self, forKey: .searchString) ?? ""
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Kodi"
            track = try container.decodeIfPresent(Int.self, forKey: .track) ?? 0
            year = try container.decodeIfPresent(Int.self, forKey: .year) ?? 0
            duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
            compilation = try container.decodeIfPresent(Bool.self, forKey: .compilation) ?? false
        }
    }
    
    /// The struct for a SongIdItem
    struct SongIdItem: Decodable {
        /// The ID of the song
        var songID: Int
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// lowerCamelCase
            case songID = "songid"
        }
    }
}
