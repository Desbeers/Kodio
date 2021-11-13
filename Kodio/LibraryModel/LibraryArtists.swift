//
//  LibraryArtists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Artists
    
    /// A struct will all artist related items
    struct Artists {
        /// All artists in the library
        var all: [ArtistItem] = []
        /// The selected artist in the UI
        var selected: ArtistItem?
    }
    
    /// Get all artists from the Kodi host
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True when loaded; else false
    func getArtists(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MyArtists", as: [ArtistItem].self) {
            artists.all = result
            return true
        } else {
            let request = AudioLibraryGetArtists()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                try Cache.set(key: "MyArtists", object: result.artists)
                artists.all = result.artists
                return true
            } catch {
                print("Loading artists failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Select or deselect an artist in the UI
    /// - Parameters artist: The selected ``ArtistItem``
    func toggleArtist(artist: ArtistItem) {
        logger("Artist selected")
        /// Reload albums and songs
        Task(priority: .userInitiated) {
            artists.selected = artists.selected == artist ? nil : artist
            /// Reset selection
            albums.selected = nil
            /// Set the selection
            setLibrarySelection(item: artists.selected)
            let songs = await filterSongs()
            /// Now the albums
            async let albums = filterAlbums(songList: songs)
            /// Update the UI
            await updateLibraryView(
                content:
                    FilteredContent(
                        genres: filteredContent.genres,
                        artists: filteredContent.artists,
                        albums: await albums,
                        songs: songs
                    )
            )
        }
    }
    
    /// Retrieve all artists (Kodi API)
    struct AudioLibraryGetArtists: KodiAPI {
        /// Method
        var method = Method.audioLibraryGetArtists
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// Get all artists
            let albumartistsonly = false
            /// The properties
            let properties = ArtistItem().properties
            /// Sort order
            let sort = Sort()
            /// Sort order struct
            struct Sort: Encodable {
                /// Sort by artist sort name
                let useartistsortname = true
                /// Sort order
                let order = SortMethod.ascending.string()
                /// Sort method
                let method = SortMethod.artist.string()
            }
        }
        /// The response struct
        struct Response: Decodable {
            /// The list or artists
            let artists: [ArtistItem]
        }
    }
    
    /// The struct for an artist item
    struct ArtistItem: LibraryItem, Identifiable, Hashable {
        /// The properties that we ask for
        var properties = ["fanart", "thumbnail", "description", "isalbumartist", "songgenres"]
        /// Make it identifiable
        var id = UUID().uuidString
        /// The media type
        let media: MediaType = .artist
        /// The SF symbol for this media item
        let icon: String = "music.mic"
        /// The name of the artist
        var artist: String = ""
        /// The ID of the artist
        var artistID: Int = 0
        /// Is this an album artist?
        var isAlbumArtist: Bool = false
        /// Fanart for the artist
        var fanart: String = ""
        /// Description of the artist
        var description: String = ""
        /// Thumbnail for the artist
        var thumbnail: String = ""
        /// An array with genres for this artist
        var songGenres = [SongGenres]()
        /// The search string
        var search: String {
            return artist
        }
        /// Name of the artist
        var title: String {
            return artist
        }
        /// Subtitle for the artist
        var subtitle: String {
            return genres.joined(separator: " · ")
        }
        /// Details for the artist
        /// - Note: Not needed, but required by protocol
        let details: String = ""
        /// An array with genres for this artist
        var genres: [String] {
            /// Make a genre list
            var genres: [String] = []
            for genre in songGenres {
                genres.append(genre.title)
            }
            return genres
        }
        /// Song genres struct
        struct SongGenres: Codable, Identifiable, Hashable {
            /// Make it identifiable
            var id = UUID()
            /// The genre ID
            var genreID: Int = 0
            /// Title of the genre
            var title: String = ""
            /// Coding keys
            enum CodingKeys: String, CodingKey {
                /// The keys
                case title
                /// lowerCamelCase
                case genreID = "genreid"
            }
        }
        /// The coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case artist, fanart, description, thumbnail
            /// lowerCamelCase
            case artistID = "artistid"
            /// lowerCamelCase
            case isAlbumArtist = "isalbumartist"
            /// lowerCamelCase
            case songGenres = "songgenres"
        }
    }
}
