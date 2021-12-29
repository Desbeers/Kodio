//
//  LibrarySongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {

    // MARK: Songs

    /// A struct with all song related items
    struct Songs {
        /// All songs in the library
        var all: [SongItem] = []
    }

    /// Get all songs from the Kodi host
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True when done
    func getSongs(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MySongs", as: [SongItem].self) {
            songs.all = result
            return true
        } else {
            let request = AudioLibraryGetSongs()
            do {
                let result = try await kodiClient.sendRequest(request: request)
                songs.all = result.songs
                /// Add some additional fields to the songs
                for (index, song) in songs.all.enumerated() {
                    if let album = albums.all.first(where: { $0.albumID == song.albumID }) {
                        /// I like to know if the song is part of a compilation and there is no property for that
                        songs.all[index].compilation = album.compilation
                        /// Sometimes a song has a different thumbnail than the album so you end-up with many, many items in the cache
                        songs.all[index].thumbnail = album.thumbnail
                        /// Try to save on expensive queries
                        songs.all[index].albumArtist = album.artist
                        songs.all[index].albumArtistID = album.artistID
                        /// Create the search string
                        songs.all[index].searchString = "\(songs.all[index].artist.first ?? "") \(songs.all[index].album) \(songs.all[index].title)"
                    }
                }
                /// Save in the cache
                try Cache.set(key: "MySongs", object: songs.all)
                /// Save the date of the last library scan in the cache
                await getLastUpdate(cache: true)
                return true
            } catch {
                /// There are no songs in the library
                print("Loading songs failed with error: \(error)")
                return true
            }
        }
    }

    /// Get a list of song ID's that are updated since last update
    /// - Parameter date: The date of the last update
    func getUpdatedSongs(date: String) async {
        logger("Updating songs")
        let request = AudioLibraryGetUpdatedSongs(date: date)
        do {
            let result = try await kodiClient.sendRequest(request: request)
            for song in result.songs {
                await getSongDetails(songID: song.songID, publish: false)
            }
            /// Save in the cache
            do {
                try Cache.set(key: "MySongs", object: songs.all)
            } catch {
                logger("Error saving MySongs")
            }
            /// Save the date of the last library scan in the cache
            await getLastUpdate(cache: true)
        } catch {
            print(error)
        }
    }

    /// Get the details from one song
    /// - Parameters:
    ///   - songID: The ID of the song
    ///   - publish: Update view and cache or not. This function is also just to update the library on start
    func getSongDetails(songID: Int, publish: Bool = true) async {
        let request = AudioLibraryGetSongDetails(songID: songID)
        do {
            let result = try await kodiClient.sendRequest(request: request)
            /// Update the fiields in the song list
            if let index = songs.all.firstIndex(where: { $0.songID == songID }) {
                songs.all[index].rating = result.songdetails.rating
                songs.all[index].playCount = result.songdetails.playCount
                songs.all[index].lastPlayed = result.songdetails.lastPlayed
                logger("Updated `\(result.songdetails.title)`")
                if publish {
                    /// Update UI
                    Task { @MainActor in
                        filteredContent.songs = await filterSongs()
                        Player.shared.queueSongs = Library.shared.getSongsFromQueue()
                    }
                    /// Save in the cache
                    do {
                        try Cache.set(key: "MySongs", object: songs.all)
                    } catch {
                        logger("Error saving MySongs")
                    }
                    /// Save the date of the last library scan in the cache
                    await getLastUpdate(cache: true)
                }
            }
        } catch {
            print(error)
        }
    }

    /// Retrieve all songs (Kodi API)
    struct AudioLibraryGetSongs: KodiAPI {
        /// Method
        let method = Method.audioLibraryGetSongs
        /// The JSON creator
        var parameters: Data {
            /// The parameters we ask for
            var params = Params()
            params.sort = sort(method: .artist, order: .ascending)
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The properties that we ask from Kodi
            let properties = SongItem().properties
            /// Sort order
            var sort = KodiClient.SortFields()
        }
        /// The response struct
        struct Response: Decodable {
            /// The list of songs
            let songs: [SongItem]
        }
    }

    /// Retrieve details of one song (Kodi API)
    struct AudioLibraryGetSongDetails: KodiAPI {
        /// Argument: the song we ask for
        var songID: Int
        /// Method
        var method = Method.audioLibraryGetSongDetails
        /// The JSON creator
        var parameters: Data {
            /// The parameters we ask for
            var params = Params()
            params.songid = songID
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The properties that we ask from Kodi
            let properties = SongItem().properties
            /// The ID of the song
            var songid: Int = 0
        }
        /// The response struct
        struct Response: Decodable {
            /// The details of the song
            var songdetails: SongItem
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
            params.playcount = song.playCount
            params.lastplayed = song.lastPlayed
            return buildParams(params: params)
        }
        /// The request struct
        /// - Note: The properties we want to set
        struct Params: Encodable {
            /// The song ID
            var songid: Int = 0
            /// The rating of the song
            var userrating: Int = 0
            /// The play count of the song
            var playcount: Int = 0
            /// The last played date
            var lastplayed: String = ""
        }
        /// The response struct
        struct Response: Decodable { }
    }

    /// Retrieve filtered song ID's (Kodi API)
    struct AudioLibraryGetUpdatedSongs: KodiAPI {
        /// Arguments
        var date: String = ""
        /// Method
        let method = Method.audioLibraryGetSongs
        /// The JSON creator
        var parameters: Data {
            /// The parameters we ask for
            var params = Params()
            params.filter.value = date
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// Filter
            var filter = Filter()
            /// The limits struct
            struct Filter: Encodable {
                /// The field of the filter
                let field = "datemodified"
                /// The operator of the filter
                let operate = "greaterthan"
                /// The value for the filter
                var value: String = ""
                /// The coding keys
                enum CodingKeys: String, CodingKey {
                    /// The keys
                    case field, value
                    /// operator is a reserved word
                    case operate = "operator"
                }
            }
        }
        /// The response struct
        struct Response: Decodable {
            /// The list of songs
            let songs: [SongID]
            /// The struct for a SongIdItem
            struct SongID: Decodable, Equatable {
                /// The ID of the song
                var songID: Int
                /// Coding keys
                enum CodingKeys: String, CodingKey {
                    /// lowerCamelCase
                    case songID = "songid"
                }
            }
        }
    }

    /// The struct for a song item
    struct SongItem: LibraryItem, Identifiable, Hashable {
        /// The properties that we ask from Kodi
        let properties = [
            "title",
            "artist",
            "artistid",
            "comment",
            "year",
            "playcount",
            "albumid",
            "track",
            "disc",
            "lastplayed",
            "album",
            "genreid",
            "dateadded",
            "genre",
            "duration",
            "userrating"
        ]
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
        /// Comment of the song
        var comment: String = ""
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
        /// Empty item message
        /// - Note: Not needed, but required by protocol
        let empty: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case album, artist, comment, genre, thumbnail, title, track, disc, year, duration, compilation, searchString
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
    }
}

extension Library.SongItem {
    /// Custom init because fields from albums will be merged and without below
    /// we can't save/load the struct to/from the cache.
    /// In an extension so we can still use the memberwise initializer.
    /// - Note: See https://sarunw.com/posts/how-to-preserve-memberwise-initializer/
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        album = try container.decodeIfPresent(String.self, forKey: .album) ?? ""
        albumID = try container.decodeIfPresent(Int.self, forKey: .albumID) ?? 0
        albumArtist = try container.decodeIfPresent([String].self, forKey: .albumArtist) ?? [""]
        albumArtistID = try container.decodeIfPresent([Int].self, forKey: .albumArtistID) ?? []
        artist = try container.decodeIfPresent([String].self, forKey: .artist) ?? [""]
        artistID = try container.decodeIfPresent([Int].self, forKey: .artistID) ?? []
        comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
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
