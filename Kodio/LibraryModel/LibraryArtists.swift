//
//  LibraryArtists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: - Artists
    
    /// get a list of all artists
    /// - Parameters:
    ///     - reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: True of loaded; else false
    func getArtists(reload: Bool = false) async -> Bool {
        self.status.artists = false
        if !reload, let artists = Cache.get(key: "MyArtists", as: [ArtistItem].self) {
            self.allArtists = artists
            return true
        } else {
            let request = AudioLibraryGetArtists()
            do {
                let result = try await KodiClient.shared.sendRequest(request: request)
                try Cache.set(key: "MyArtists", object: result.artists)
                allArtists = result.artists
                return true
            } catch {
                print("Loading artists failed with error: \(error)")
                return false
            }
        }
    }
    
    /// Select or deselect an artist in the UI
    /// - Parameters:
    ///   - artist: The selected artist
    ///   - force: Force selection; don't toggle it
    func toggleArtist(artist: ArtistItem, force: Bool = false) {
        logger("Artist selected")
        selectedArtist = force ? artist : selectedArtist == artist ? nil : artist
        /// Reset selection
        selectedAlbum = nil
        /// Set the filter
        setFilter(item: selectedArtist)
        /// Reload media
        Task {
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
    
    /// Filter the library based on artist
    func filterArtists(songList: [SongItem]) async -> [ArtistItem] {
        var artistList = allArtists
        /// Show only album artists when that is selected in the sidebar
        if selectedSmartList.media == .albumArtists {
            artistList = artistList.filter {$0.isAlbumArtist == true}
        }
        /// Filter artists based on songs list
        let filter = songList.map { song -> [Int] in
            return song.artistID
        }
        let artists: [Int] = filter.flatMap { $0 }.removingDuplicates()
        return artistList.filter({artists.contains($0.artistID)}).sorted {$0.artist < $1.artist}
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
            let albumartistsonly = false
            let properties = ArtistItem().properties
            let sort = Sort()
            struct Sort: Encodable {
                let useartistsortname = true
                let order = SortMethod.ascending.string()
                let method = SortMethod.artist.string()
            }
        }
        /// The response struct
        struct Response: Decodable {
            let artists: [ArtistItem]
        }
    }
    
    /// The struct for an artist item
    struct ArtistItem: LibraryItem {
        /// The fields that we ask for
        var properties = ["fanart", "thumbnail", "description", "isalbumartist", "songgenres"]
        /// Make it identifiable
        var id = UUID()
        /// The filter type
        let media: MediaType = .artists
        let icon: String = "music.mic"
        /// The fields from above
        var artist: String = ""
        var artistID: Int = 0
        var isAlbumArtist: Bool = false
        var fanart: String = ""
        var description: String = ""
        var thumbnail: String = ""
        var songGenres = [SongGenres]()
        /// Computed stuff
        var search: String {
            return artist
        }
        var title: String {
            return artist
        }
        var subtitle: String {
            return genres.joined(separator: " · ")
        }
        var genres: [String] {
            var genres: [String] = []
            for genre in songGenres {
                genres.append(genre.title)
            }
            return genres
        }
        /// Song genres
        struct SongGenres: Codable, Identifiable, Hashable {
            /// Make it identifiable
            var id = UUID()
            var genreID: Int = 0
            var title: String = ""
            enum CodingKeys: String, CodingKey {
                case title
                case genreID = "genreid"
            }
        }
        enum CodingKeys: String, CodingKey {
            case artist, fanart, description, thumbnail
            case artistID = "artistid"
            case isAlbumArtist = "isalbumartist"
            case songGenres = "songgenres"
        }
    }
}
