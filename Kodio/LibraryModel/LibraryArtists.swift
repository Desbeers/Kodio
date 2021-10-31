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
        artists.selected = artists.selected == artist ? nil : artist
        /// Reset selection
        albums.selected = nil
        /// Set the filter
        setLibraryFilter(item: artists.selected)
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
    
    /// Filter the artists
    /// - Parameter songList: The current filtered list of songs
    /// - Returns: An array of artist items
    func filterArtists(songList: [SongItem]) async -> [ArtistItem] {
        var artistList = artists.all
        /// Show only album artists when that is selected in the sidebar
        if smartLists.selected.media == .albumArtists {
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
        /// /// The properties that we ask from Kodi
        var properties = ["fanart", "thumbnail", "description", "isalbumartist", "songgenres"]
        /// Make it identifiable
        var id = UUID()
        /// The media type
        let media: MediaType = .artist
        /// The SF symbol for this media item
        let icon: String = "music.mic"
        /// The properties (and defaults)
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
