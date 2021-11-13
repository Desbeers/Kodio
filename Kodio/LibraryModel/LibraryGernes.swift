//
//  LibraryGernes.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Genres
    
    /// A struct will all genre related items
    struct Genres {
        /// All genres in the library
        var all: [GenreItem] = []
        /// The selected genre in the UI
        var selected: GenreItem?
    }
    
    /// Get all genres from the Kodi host
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True when loaded; else false
    func getGenres(reload: Bool = false) async -> Bool {
        if !reload, let result = Cache.get(key: "MyGenres", as: [GenreItem].self) {
            genres.all = result
            return true
        } else {
            let request = AudioLibraryGetGenres()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                try Cache.set(key: "MyGenres", object: result.genres)
                genres.all = result.genres
                return true
            } catch {
                print("Loading genres failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Select or deselect a genre in the UI
    /// - Parameter genre: The selected  ``GenreItem``
    func toggleGenre(genre: GenreItem) {
        logger("Genre selected")
        /// Reload artists, albums and songs
        Task(priority: .userInitiated) {
            genres.selected = genres.selected == genre ? nil : genre
            /// Reset selection
            artists.selected = nil
            albums.selected = nil
            /// Set the selection
            setLibrarySelection(item: genres.selected)
            /// Filter songs first; all the rest is based on it.
            let songs = await filterSongs()
            /// Now the rest
            async let albums = filterAlbums(songList: songs)
            async let artists = filterArtists(songList: songs)
            /// Update the UI
            await updateLibraryView(
                content:
                    FilteredContent(
                        genres: filteredContent.genres,
                        artists: await artists,
                        albums: await albums,
                        songs: songs
                    )
            )
        }
    }

    /// Retrieve all genres (Kodi API)
    struct AudioLibraryGetGenres: KodiAPI {
        /// Method
        var method = Method.audioLibraryGetGenres
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// Sort order
            let sort = Sort()
            /// The sort order struct
            struct Sort: Encodable {
                /// Sort order
                let order = "ascending"
                /// Sort method
                let method = "label"
            }
        }
        /// The response struct
        struct Response: Decodable {
            /// A list with genres
            let genres: [GenreItem]
        }
    }
    
    /// The struct for a genre item
    struct GenreItem: LibraryItem, Identifiable, Hashable {
        var id = UUID().uuidString
        /// The media type
        let media: MediaType = .genre
        /// The SF symbol for this media item
        let icon: String = "music.quarternote.3"
        /// The genre ID
        var genreID: Int = 0
        /// Label of the genre
        var label: String = ""
        /// Title of the genre
        var title: String {
            return label
        }
        /// Subtitle of the genre
        var subtitle: String = "All songs in this genre"
        /// Description of the genre
        /// - Note: Not needed, but required by protocol
        var description: String = ""
        /// Thumbnail of the genre
        /// - Note: Not needed, but required by protocol
        let thumbnail: String = ""
        /// Fanart of the genre
        /// - Note: Not needed, but required by protocol
        let fanart: String = ""
        /// Details for the genre
        /// - Note: Not needed, but required by protocol
        let details: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case label
            /// lowerCamelCase
            case genreID = "genreid"
        }
    }
}
