///
/// Genres.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

extension KodiClient {
    // MARK: - GenreLists (struct)
    struct GenreLists {
        var all = [GenreFields]()
    }

    // MARK: - get a list of genres

    func getGenres(reload: Bool) {
        self.library.genres = false
        if !reload, let genres = self.getCache(key: "MyGenres", as: [GenreFields].self) {
            self.genres.all = genres
            self.library.genres = true
        } else {
            let request = AudioLibraryGetGenres()
            sendRequest(request: request) { [weak self] result in
                switch result {
                case .success(let result):
                    guard let results = result?.result.genres else {
                        return
                    }
                    do {
                        try self?.setCache(key: "MyGenres", object: results)
                    } catch {
                        self?.log(#function, "Error saving MyGenres")
                    }
                    self?.library.genres = true
                    self?.genres.all = results
                case .failure(let error):
                    self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - AudioLibrary.GetGenres (API request)

struct AudioLibraryGetGenres: KodiRequest {
    /// Method
    var api = KodiAPI.audioLibraryGetGenres
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    /// The request struct
    struct Params: Encodable {
        let sort = Sort()
        struct Sort: Encodable {
            let order = "ascending"
            let method = "label"
        }
    }
    // typealias response = Response
    /// The response struct
    struct Response: Decodable {
        let genres: [GenreFields]
    }
}

// MARK: - GenreFields (struct)

/// The fields for a genre

struct GenreFields: Codable, Identifiable, Hashable {
    var id = UUID()
    let genreID: Int
    let label: String
}

extension GenreFields {
    enum CodingKeys: String, CodingKey {
        case label
        case genreID = "genreid"
    }
}
