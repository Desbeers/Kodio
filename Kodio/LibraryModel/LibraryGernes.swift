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
        genres.selected = genres.selected == genre ? nil : genre
        /// Reset selection
        artists.selected = nil
        albums.selected = nil
        /// Set the filter
        setLibraryFilter(item: genres.selected)
        /// Reload media
        Task {
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

    /// Filter the genres
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of genre items
    func filterGenres(songList: [SongItem]) async -> [GenreItem] {
        /// Filter genres based on song list
        let filter = songList.map { song -> [Int] in
            return song.genreID
        }
        let genreIDs: [Int] = filter.flatMap { $0 }.removingDuplicates()
        return genres.all.filter({genreIDs.contains($0.genreID)})
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
            let sort = Sort()
            struct Sort: Encodable {
                let order = "ascending"
                let method = "label"
            }
        }
        /// The response struct
        struct Response: Decodable {
            let genres: [GenreItem]
        }
    }
    
    /// The struct for a genre item
    struct GenreItem: LibraryItem {
        var id = UUID()
        /// The filter type
        let media: MediaType = .genre
        let icon: String = "music.quarternote.3"
        var genreID: Int = 0
        var label: String = ""
        var title: String {
            return label
        }
        var subtitle: String = "All songs in this genre"
        var description: String = ""
        /// Not needed, but required by protocol
        let thumbnail: String = ""
        let fanart: String = ""
        enum CodingKeys: String, CodingKey {
            case label
            case genreID = "genreid"
        }
    }
}
