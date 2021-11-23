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
    /// - Returns: True when done
    func getAlbums(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MyAlbums", as: [AlbumItem].self) {
            albums.all = result
            return true
        } else {
            let request = AudioLibraryGetAlbums()
            do {
                let result = try await kodiClient.sendRequest(request: request)
                try Cache.set(key: "MyAlbums", object: result.albums)
                albums.all = result.albums
                return true
            } catch {
                /// There are no albums in the library
                print("Loading albums failed with error: \(error)")
                return true
            }
        }
    }

    /// Select or deselect an album in the UI
    /// - Parameter album: The selected ``AlbumItem``
    /// - Returns: False when done to enable the buttons again in the view
    func toggleAlbum(album: AlbumItem) async -> Bool {
        logger("Album selected")
        /// Reload songs
        albums.selected = albums.selected == album ? nil : album
        /// Set the selection
        setLibrarySelection(item: albums.selected)
        /// Filter the songs
        async let songs = filterSongs()
        /// Update the UI
        await updateLibraryView(
            content:
                FilteredContent(
                    genres: filteredContent.genres,
                    artists: filteredContent.artists,
                    albums: filteredContent.albums,
                    songs: await songs
                )
        )
        /// Return the filtering state to the view
        return false
    }
    
    /// Retrieve all albums (Kodi API)
    struct AudioLibraryGetAlbums: KodiAPI {
        /// Method
        var method = Method.audioLibraryGetAlbums
        /// The JSON creator
        var parameters: Data {
            var params = Params()
            params.sort.method = KodiClient.SortMethod.artist.string()
            params.sort.order = KodiClient.SortMethod.ascending.string()
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The properties
            let properties = AlbumItem().properties
            /// Sort order
            var sort = KodiClient.SortFields()
        }
        /// The response struct
        struct Response: Decodable {
            /// The list of albums
            let albums: [AlbumItem]
        }
    }
    
    /// The struct for an album item
    struct AlbumItem: LibraryItem, Identifiable, Hashable {
        /// /// The properties that we ask from Kodi
        var properties = ["artistid", "artist", "description", "title", "year", "playcount", "totaldiscs",
                          "genre", "thumbnail", "compilation", "dateadded", "lastplayed"]
        /// Make it identifiable
        var id = UUID().uuidString
        /// The media type
        let media: MediaType = .album
        /// The SF symbol for this media item
        let icon: String = "square.stack"
        /// The ID of an album
        var albumID: Int = 0
        /// An array with artist names
        var artist: [String] = [""]
        /// An array with artist ID's
        var artistID: [Int] = [0]
        /// Is this a compilation album?
        var compilation: Bool = false
        /// Date that the album is added
        var dateAdded: String = ""
        /// Date that the album is last played
        var lastPlayed: String = ""
        /// An array with thee album genres
        var genre: [String] = [""]
        /// Description of the album
        var description: String = ""
        /// Play count of the album
        var playCount: Int = 0
        /// Total disks for this album
        var totalDiscs: Int = 0
        /// The tumbnail for the album
        var thumbnail: String = ""
        /// The album title
        var title: String = ""
        /// Year of the album
        var year: Int = 0
        /// Subtitle for the album
        var subtitle: String {
            return artist.joined(separator: " & ")
        }
        /// Details of the album
        var details: String {
            var details: [String] = []
            if year > 0 {
                details.append(String(year))
            }
            return (details + genre).joined(separator: "・")
        }
        /// Search string
        var search: String {
            return "\(artist) \(title)"
        }
        /// Album fanart
        /// - Note: Not needed, but required by protocol
        let fanart: String = ""
        /// Empty item message
        /// - Note: Not needed, but required by protocol
        let empty: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case artist, compilation, description, genre, thumbnail, title, year
            /// lowerCamelCase
            case albumID = "albumid"
            /// lowerCamelCase
            case artistID = "artistid"
            /// lowerCamelCase
            case dateAdded = "dateadded"
            /// lowerCamelCase
            case lastPlayed = "lastplayed"
            /// lowerCamelCase
            case playCount = "playcount"
            /// lowerCamelCase
            case totalDiscs = "totaldiscs"
        }
    }
}
