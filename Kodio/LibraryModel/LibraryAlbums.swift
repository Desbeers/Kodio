//
//  LibraryAlbums.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Albums
    
    /// A struct will all album related items
    struct Albums {
        /// All albums in the library
        var all: [AlbumItem] = []
        /// The selected artist in the UI
        var selected: AlbumItem?
    }
    
    /// Get all albums from the Kodi host
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True when loaded; else false
    func getAlbums(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MyAlbums", as: [AlbumItem].self) {
            albums.all = result
            return true
        } else {
            let request = AudioLibraryGetAlbums()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                try Cache.set(key: "MyAlbums", object: result.albums)
                albums.all = result.albums
                return true
            } catch {
                print("Loading albums failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Select or deselect an album in the UI
    /// - Parameters album: The selected ``AlbumItem``
    func toggleAlbum(album: AlbumItem) {
        logger("Album selected")
        albums.selected = albums.selected == album ? nil : album
        /// Set the filter
        setLibraryFilter(item: albums.selected)
        /// Reload songs
        Task {           
            let songs = await filterSongs()
            /// Update the UI
            await updateLibraryView(
                content:
                    FilteredContent(
                        genres: filteredContent.genres,
                        artists: filteredContent.artists,
                        albums: filteredContent.albums,
                        songs: songs
                    )
            )
        }
    }
    
    /// Filter the albums
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of album items
    func filterAlbums(songList: [SongItem]) async -> [AlbumItem] {
        let albumList = albums.all
        /// Filter albums based on songs list
        let allAlbums = songList.map { song -> Int in
            return song.albumID
        }
        let albumIDs = allAlbums.removingDuplicates()
        return albumList
            .filter({albumIDs.contains($0.albumID)})
            .sorted { $0.artist == $1.artist ? $0.year < $1.year : $0.artist.first! < $1.artist.first! }
    }
    
    /// Retrieve all albums (Kodi API)
    struct AudioLibraryGetAlbums: KodiAPI {
        /// Method
        var method = Method.audioLibraryGetAlbums
        /// The JSON creator
        var parameters: Data {
            var params = Params()
            params.sort.method = SortMethod.artist.string()
            params.sort.order = SortMethod.ascending.string()
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            let properties = AlbumItem().properties
            var sort = SortFields()
        }
        /// The response struct
        struct Response: Decodable {
            let albums: [AlbumItem]
        }
    }
    
    /// The struct for an album item
    struct AlbumItem: LibraryItem {
        /// /// The properties that we ask from Kodi
        var properties = ["artistid", "artist", "description", "title", "year", "playcount", "totaldiscs",
                          "genre", "thumbnail", "compilation", "dateadded", "lastplayed"]
        /// Make it identifiable
        var id = UUID()
        /// The media type
        let media: MediaType = .album
        /// The SF symbol for this media item
        let icon: String = "square.stack"
        /// The properties (and defaults)
        var albumID: Int = 0
        var artist: [String] = [""]
        var artistID: [Int] = [0]
        var compilation: Bool = false
        var dateAdded: String = ""
        var lastPlayed: String = ""
        var genre: [String] = [""]
        var description: String = ""
        var playCount: Int = 0
        var totalDiscs: Int = 0
        var thumbnail: String = ""
        var title: String = ""
        var year: Int = 0
        /// Computed stuff
        var subtitle: String {
            return artist.joined(separator: " & ")
        }
        var details: String {
            var details: [String] = []
            if year > 0 {
                details.append(String(year))
            }
            return (details + genre).joined(separator: "・")
        }
        var search: String {
            return "\(artist) \(title)"
        }
        /// Not needed, but required by protocol
        let fanart: String = ""
        enum CodingKeys: String, CodingKey {
            case artist, compilation, description, genre, thumbnail, title, year
            case albumID = "albumid"
            case artistID = "artistid"
            case dateAdded = "dateadded"
            case lastPlayed = "lastplayed"
            case playCount = "playcount"
            case totalDiscs = "totaldiscs"
        }
    }
}
