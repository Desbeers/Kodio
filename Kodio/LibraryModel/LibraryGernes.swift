//
//  LibraryGernes.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: - Genres
    
    /// Get a list with all genres
    func getGenres(reload: Bool = false) async -> Bool {
        self.status.genres = false
        if !reload, let genres = Cache.get(key: "MyGenres", as: [GenreItem].self) {
            allGenres = genres
            return true
        } else {
            let request = AudioLibraryGetGenres()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                try Cache.set(key: "MyGenres", object: result.genres)
                allGenres = result.genres
                return true
            } catch {
                print("Loading genres failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Select or deselect a genre in the UI
    /// - Parameters:
    ///   - genre: The selected genre
    func toggleGenre(genre: GenreItem) {
        logger("Genre selected")
        selectedGenre = selectedGenre == genre ? nil : genre
        /// Reset selection
        selectedArtist = nil
        selectedAlbum = nil
        /// Set the filter
        setFilter(item: selectedGenre)
        /// Reload media
        Task { @MainActor in
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
    
    /// Filter the library based on genre
    func filterGenres(songList: [SongItem]) async -> [GenreItem] {
        /// Filter genres based on song list
        let filter = songList.map { song -> [Int] in
            return song.genreID
        }
        let genres: [Int] = filter.flatMap { $0 }.removingDuplicates()
        return allGenres.filter({genres.contains($0.genreID)})
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
        let media: MediaType = .genres
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
