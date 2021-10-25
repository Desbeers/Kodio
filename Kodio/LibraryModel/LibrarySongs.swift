//
//  LibrarySongs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: - Songs
    
    /// get a list of all songs
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True of loaded; else false
    func getSongs(reload: Bool = false) async -> Bool {
        self.status.songs = false
        if !reload, let songs = Cache.get(key: "MySongs", as: [SongItem].self) {
            self.allSongs = songs
            return true
        } else {
            let request = AudioLibraryGetSongs()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                allSongs = result.songs
                /// Add some album fields to the songs
                mergeSongsAndAlbums()
                /// Save in the cache
                try Cache.set(key: "MySongs", object: allSongs)
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
        for (index, song) in allSongs.enumerated() {
            if let album = allAlbums.first(where: { $0.albumID == song.albumID }) {
                /// I like to know if the song is part of a compilation
                /// and there is no property for that
                allSongs[index].compilation = album.compilation
                /// Sometimes a song has a different thumbnail than the album
                /// so you end-up with many, many items in the cache
                allSongs[index].thumbnail = album.thumbnail
                /// Try to save on expensive queries
                allSongs[index].albumArtist = album.artist
                allSongs[index].albumArtistID = album.artistID
                /// Create the search string
                allSongs[index].searchString = "\(allSongs[index].artist.first ?? "") \(allSongs[index].album) \(allSongs[index].title)"
            }
        }
    }
    
    /// Filter the library based on songs
    func filterSongs() async -> [SongItem] {
        var songList = allSongs
        switch selectedSmartList.media {
        case .search:
            let smartSearchMatcher = SmartSearchMatcher(searchString: query)
            songList = songList.filter { songs in
                    if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(songs.searchString) {
                        return true
                    }
                    return smartSearchMatcher.matches(songs.searchString)
                }
        case .compilations:
            songList = songList.filter {$0.compilation == true}.sorted {$0.artists < $1.artists}
        case .recentlyPlayed:
            songList = recentlyPlayedSongs
        case .recentlyAdded:
            songList = Array(songList.sorted {$0.dateAdded > $1.dateAdded}.prefix(100))
        case .mostPlayed:
            songList = mostPlayedSongs
        case .random:
            songList = randomSongs
        case .neverPlayed:
            songList = neverPlayedSongs
        case .playlist:
            songList = playlistSongs
        case .favorites:
            songList = songList.filter { $0.rating > 0 }.sorted {$0.rating > $1.rating}
        case .queue:
            songList = Queue.shared.songs
        default:
            songList = songList.filter {$0.compilation == false}
        }
        /// Filter on a genre if one is selected
        if let genre = selectedGenre {
            songList = songList.filter { $0.genre.contains(genre.label)}
        }
        /// Filter on an artist if one is selected
        if let artist = selectedArtist {
            songList = songList.filter {$0.artist.contains(artist.artist)}.sorted {$0.title < $1.title}
        }
        /// Filter on an album if one is selected
        if let album = selectedAlbum {
            /// Filter by disc and then by track
            songList = songList.filter { $0.albumID == album.albumID }
                .sorted { $0.disc == $1.disc ? $0.track < $1.track : $0.disc < $1.disc }
        }
        /// Give the list a new ID
        songListID = UUID().uuidString
        /// Return the list of filtered songs
        return songList
    }
    
    /// Like or dislike a song
    func favoriteSongToggle(song: SongItem) {
        if let index = allSongs.firstIndex(where: { $0.songID == song.songID }),
           let list = filteredContent.songs.firstIndex(where: { $0.songID == song.songID }) {
            if song.rating == 0 {
                allSongs[index].rating = 10
                filteredContent.songs[list].rating = 10
            } else {
                allSongs[index].rating = 0
                filteredContent.songs[list].rating = 0
            }
            /// Save it on the host
            setSongDetails(song: allSongs[index])
            /// Save in the cache
            do {
                try Cache.set(key: "MySongs", object: allSongs)
            } catch {
                logger("Error saving MySongs")
            }
            /// Reload library if viewing favorites
            if media == .favorites {
                filterAllMedia()
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
            var params = Params()
            params.sort.method = SortMethod.artist.string()
            params.sort.order = SortMethod.ascending.string()
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The fields that we ask for
            let properties = ["title", "artist", "artistid", "year", "playcount", "albumid",
                              "track", "disc", "lastplayed", "album", "genreid",
                              "dateadded", "genre", "duration", "userrating"]
            var sort = SortFields()
        }
        /// The response struct
        struct Response: Decodable {
            let songs: [SongItem]
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
            var params = Params()
            params.songid = song.songID
            params.userrating = song.rating
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The fields that we ask for
            var songid: Int = 0
            var userrating: Int = 0
        }
        /// The response struct
        struct Response: Decodable { }
    }
    
    /// The struct for a song item
    struct SongItem: LibraryItem {
        /// Make it indentifiable
        var id = UUID()
        let media: MediaType = .songs
        let icon: String = "music.note"
        /// The fields from above
        var album: String = ""
        var albumID: Int = 0
        var albumArtist: [String] = []
        var albumArtistID: [Int] = []
        var artist: [String] = []
        var artistID: [Int] = []
        var dateAdded: String = ""
        var genre: [String] = []
        var genreID: [Int] = []
        var lastPlayed: String = ""
        var playCount: Int = 0
        var songID: Int = 0
        var rating: Int = 0
        var thumbnail: String = ""
        var title: String = ""
        var disc: Int = 0
        var track: Int = 0
        var year: Int = 0
        var duration: Int = 0
        /// Not a Kodi property, so manualy added
        var compilation: Bool = false
        /// This is for the player queue and its not a 'property'
        var queueID = -1
        /// Search string; will be filled-in later
        var searchString: String = ""
        /// Computed stuff
        var subtitle: String {
            return artist.joined(separator: " & ")
        }
        var description: String = ""
        var artists: String {
            return artist.joined(separator: " & ")
        }
        /// Not needed, but required by protocol
        let fanart: String = ""
        /// JSON coding keys
        enum CodingKeys: String, CodingKey {
            case album, artist, genre, thumbnail, title, track, disc, year, duration, compilation, searchString
            case albumID = "albumid"
            case artistID = "artistid"
            case albumArtist = "albumartist"
            case albumArtistID = "albumartistid"
            case dateAdded = "dateadded"
            case genreID = "genreid"
            case lastPlayed = "lastplayed"
            case playCount = "playcount"
            case songID = "songid"
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
    
    /// Retrieve filtered songs by ID (Kodi API)
    struct AudioLibraryGetSongIDs: KodiAPI {
        /// Arguments
        var media: MediaType = .songs
        /// Method
        var method = Method.audioLibraryGetSongs
        /// The JSON creator
        var parameters: Data {
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
            var sort = SortFields()
            var limits = Limits()
            struct Limits: Encodable {
                let start = 0
                let end = 25
            }
        }
        /// The response struct
        struct Response: Decodable {
            let songs: [SongIdItem]
        }
    }
    
    /// The struct for a SongIdItem
    struct SongIdItem: LibraryItem {
        var id = UUID()
        var songID: Int
        var media: MediaType = .songs
        /// Not used, but required by protocol
        var title: String = ""
        var subtitle: String = ""
        var description: String = ""
        let icon: String = "music.note"
        /// Not needed, but required by protocol
        let thumbnail: String = ""
        let fanart: String = ""
        enum CodingKeys: String, CodingKey {
            case songID = "songid"
        }
    }
}
