///
/// Albums.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

class Albums: ObservableObject {
    /// Use a shared instance
    static let shared = Albums()
    @Published var list = [AlbumFields]()
    var filter: FilterType {
        didSet {
            list = KodiClient.shared.albumsFilter
        }
    }
    @Published var selectedAlbum: AlbumFields? {
        didSet {
            /// Album can be nilled and then it should not do below, so check
            if selectedAlbum != nil {
                Songs.shared.filter = .album
                AppState.shared.tabs.tabDetails = .songs
            }
        }
    }
    init() {
        filter = .compilations
    }
}

// MARK: - Albums related stuff (KodiClient extension)

extension KodiClient {

    // MARK: AlbumLists (struct)

    /// The list of all album types
    struct AlbumLists {
        var all = [AlbumFields]()
        var recentlyPlayed = [AlbumFields]()
        var mostPlayed = [AlbumFields]()
        var random = [AlbumFields]()
    }

    // MARK: getAlbums (function)

    /// get a list of all albums
    /// - Parameter reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: An array of all albums

    func getAlbums(reload: Bool) {
        self.library.albums = false
        if !reload, let albums = self.getCache(key: "MyAlbums", as: [AlbumFields].self) {
            self.library.albums = true
            self.albums.all = albums
        } else {
            let request = AudioLibraryGetAlbums()
            sendRequest(request: request) { [weak self] result in
                switch result {
                case .success(let result):
                    guard let results = result?.result.albums else {
                        return
                    }
                    do {
                        try self?.setCache(key: "MyAlbums", object: results)
                    } catch {
                        self?.log(#function, "Error saving MyAlbums")
                    }
                    self?.library.albums = true
                    self?.albums.all = results
                case .failure(let error):
                    self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: albumsFilter (variable)
    
    /// Filter the albums for the SwiftUI lists
    var albumsFilter: [AlbumFields] {
        let filter = Albums.shared.filter
        switch filter {
        case .artist:
            return albums.all.filter {$0.artistID.contains(Artists.shared.selectedArtist?.artistID ?? 0)}
        case .compilations:
            return albums.all.filter {$0.compilation == true}.sorted {$0.title < $1.title}
        case .recentlyAdded:
            return Array(albums.all.sorted {$0.dateAdded > $1.dateAdded}.prefix(10))
        case .mostPlayed:
            return albums.mostPlayed
        case .recentlyPlayed:
            return albums.recentlyPlayed
        case .genre:
            return albums.all.filter { $0.genre.contains(Genres.shared.selectedGenre?.label ?? "") }
                .sorted { $0.artist.first! < $1.artist.first! }
        default:
            return albums.all
        }
    }

    // MARK: getAlbumsSmartLists (function)

    /// Get a list of recently played and recently added albums
    func getAlbumsSmartLists() {
        let recent = AudioLibraryGetAlbums(filter: .recentlyPlayed)
        sendRequest(request: recent) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.albums else {
                    return
                }
                self?.albums.recentlyPlayed = results
                self?.library.albumsRecent = true
                self?.log(#function, "Recently played albums loaded")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
        let most = AudioLibraryGetAlbums(filter: .mostPlayed)
        sendRequest(request: most) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.albums else {
                    return
                }
                self?.albums.mostPlayed = results
                self?.library.albumsMost = true
                self?.log(#function, "Most played albums loaded")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - AudioLibrary.GetAlbums (API request)

/// Get a list of albums

struct AudioLibraryGetAlbums: KodiRequest {
    /// Arguments
    var filter: FilterType = .none
    /// Method
    var method = Method.audioLibraryGetAlbums
    /// The JSON creator
    var parameters: Data {
        var params = Params()
        switch filter {
        case .recentlyPlayed:
            params.sort.method = SortFields.lastPlayed.string()
            params.sort.order = SortFields.descending.string()
            params.limits.end = 25
        case .mostPlayed:
            params.sort.method = SortFields.playCount.string()
            params.sort.order = SortFields.descending.string()
            params.limits.end = 25
        default:
            params.sort.method = SortFields.year.string()
            params.sort.order = SortFields.ascending.string()
        }
        return buildParams(params: params)
    }
    /// The request struct
    struct Params: Encodable {
        let properties = AlbumFields().properties
        var sort = Sort()
        struct Sort: Encodable {
            var order = ""
            var method = ""
        }
        var limits = Limits()
        struct Limits: Encodable {
            let start = 0
            var end = 100000
        }
    }
    // typealias response = Response
    /// The response struct
    struct Response: Decodable {
        let albums: [AlbumFields]
    }
}

// MARK: - AlbumFields (struct)

/// The fields for an album
struct AlbumFields: Codable, Identifiable, Hashable {
    /// The fields that we ask for
    var properties = ["artistid", "artist", "description", "title", "year", "playcount",
                      "genre", "thumbnail", "compilation", "dateadded", "lastplayed"]
    /// Make it identifiable
    var id = UUID()
    /// The fields from above
    var albumID: Int = 0
    var artist: [String] = [""]
    var artistID: [Int] = [0]
    var compilation: Bool = false
    var dateAdded: String = ""
    var lastPlayed: String = ""
    var genre: [String] = [""]
    var description: String = ""
    var playCount: Int = 0
    var thumbnail: String = ""
    var title: String = ""
    var year: Int = 0
    /// Computed stuff
    var details: [String] {
        var details: [String] = []
        if year > 0 {
            details.append(String(year))
        }
        return details + genre
    }
    var search: String {
        return "\(artist) \(title)"
    }
    var playCountLabel: String {
        return (playCount == 0 ? "Never played" : playCount == 1 ? "Played 1 time" : "Played \(playCount) times")
    }
}

extension AlbumFields {
    enum CodingKeys: String, CodingKey {
        case artist, compilation, description, genre, thumbnail, title, year
        case albumID = "albumid"
        case artistID = "artistid"
        case dateAdded = "dateadded"
        case lastPlayed = "lastplayed"
        case playCount = "playcount"
    }
}
