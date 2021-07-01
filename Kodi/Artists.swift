///
/// Artists.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

class Artists: ObservableObject {
    /// Use a shared instance
    static let shared = Artists()
    @Published var list = [ArtistFields]()
    @Published var filter: FilterType = .compilations
}

// MARK: - Artists related stuff (KodiClient extension)

extension KodiClient {

    // MARK: ArtistLists (struct)

    /// The list of all artist types
    struct ArtistLists {
        var all = [ArtistFields]()
    }

    // MARK: getArtists (function)

    /// get a list of all artists
    /// - Parameters:
    ///     - reload: Force a reload or else it will try to load it from the  cache
    /// - Returns: It will update the KodiClient variables

    func getArtists(reload: Bool) {
        self.library.artists = false
        if !reload, let artists = self.getCache(key: "MyArtists", as: [ArtistFields].self) {
            self.library.artists = true
            self.artists.all = artists
        } else {
            let request = AudioLibraryGetArtists()
            sendRequest(request: request) { [weak self] result in
                switch result {
                case .success(let result):
                    guard let results = result?.result.artists else {
                        return
                    }
                    do {
                        try self?.setCache(key: "MyArtists", object: results)
                    } catch {
                        self?.log(#function, "Error saving MyArtists")
                    }
                    self?.library.artists = true
                    self?.artists.all = results
                case .failure(let error):
                    self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: artistlist ID  (Variable)

    /// The SwiftUI list should have a unique ID for each list to speed-up the view
    var artistListID: String {
        if searchQuery.isEmpty {
            return "artists"
        } else {
            return searchID
        }
    }

    // MARK: artistsFilter (Variable)

    /// Filter the albums for the SwiftUI list
    var artistsFilter: [ArtistFields] {
        return artists.all
//        let appState = AppState.shared
//        print("Artist filter: \(appState.filter.artists)")
//        if searchQuery.isEmpty {
//            return artists.all
//        } else {
//            return artists.all.filterArtists()
//            //return artists.all.filter({ $0.search.folding(options: .diacriticInsensitive, locale: Locale.current).localizedCaseInsensitiveContains(self.searchQuery)})
//        }
    }

    // MARK: hideArtistLabel (function)

    /// In the SongView I like to hide 'double' information. If an artist is selected,
    /// there is not need to show the Artist Label in the View unless the
    /// album artist is not the same as the song artist.
    ///
    /// - Parameter song: the song object
    /// - Returns: Bool: true when the label needs to he hidden

    func hideArtistLabel(song: SongFields) -> Bool {
        let appState = AppState.shared
        if appState.selectedArtist != nil {
            if song.albumArtist.first == song.artist.first {
                return true
            }
        }
        return false
    }
}

// MARK: - AudioLibrary.GetArtists (API request)

struct AudioLibraryGetArtists: KodiRequest {
    /// Method
    var api = KodiAPI.audioLibraryGetArtists
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    /// The request struct
    struct Params: Encodable {
        let albumartistsonly = false
        let properties = ArtistFields().properties
        let sort = Sort()
        struct Sort: Encodable {
            let useartistsortname = true
            let order = SortFields.ascending.string()
            let method = SortFields.artist.string()
        }
    }
    /// The response struct
    // typealias response = Response
    struct Response: Decodable {
        let artists: [ArtistFields]
    }
}

// MARK: - ArtistFields (struct)

/// The fields for an artist

struct ArtistFields: Codable, Identifiable, Hashable {
    /// The fields that we ask for
    var properties = ["fanart", "thumbnail", "description", "isalbumartist"]
    /// Make it identifiable
    var id = UUID()
    /// The fields from above
    var artist: String = ""
    var artistID: Int = 0
    var isAlbumArtist: Bool = false
    var fanart: String = ""
    var description: String = ""
    var thumbnail: String = ""
    /// Computed stuff
    var search: String {
        return artist
    }
}

extension ArtistFields {
    enum CodingKeys: String, CodingKey {
        case artist, fanart, description, thumbnail
        case artistID = "artistid"
        case isAlbumArtist = "isalbumartist"
    }
}
