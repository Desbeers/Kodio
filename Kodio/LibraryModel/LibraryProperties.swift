//
//  LibraryProperties.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

extension Library {
    
    // MARK: Properties
    
    /// Get the date/time of the last audio database update
    /// - Parameter cache: store in the local cache or not
    func getLastUpdate(cache: Bool = false) async {
        let request = AudioLibraryGetProperties()
        
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
            /// Save if cache is true
            if cache {
                try Cache.set(key: "LibraryLastUpdated", object: result)
            } else {
                if let cache = Cache.get(key: "LibraryLastUpdated", as: Properties.self),
                   cache.songsModified == result.songsModified,
                   cache.songsLastAdded == result.songsLastAdded,
                   cache.albumsModified == result.albumsModified,
                   cache.albumsLastAdded == result.albumsLastAdded {
                } else {
                    logger("Library is out of date.")
                    let appState: AppState = .shared
                    await appState.viewAlert(type: .outdatedLibrary)
                }
            }
        } catch {
            print(error)
        }
    }

    /// Get the properties of the audio library (Kodi API)
    struct AudioLibraryGetProperties: KodiAPI {
        /// Arguments
        var method: Method = .audioLibraryGetProperties
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// The properties we ask for
            let properties = ["songslastadded", "songsmodified", "albumslastadded", "albumsmodified"]
        }
        /// The response struct
        typealias Response = Properties
    }

    /// The struct for the library properties
    struct Properties: Codable {
        /// Last added songs
        var songsLastAdded: String = ""
        /// Last modified songs
        var songsModified: String = ""
        /// Last added albums
        var albumsLastAdded: String = ""
        /// Last modified albums
        var albumsModified: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// lowerCamelCase
            case songsLastAdded = "songslastadded"
            /// lowerCamelCase
            case songsModified = "songsmodified"
            /// lowerCamelCase
            case albumsLastAdded = "albumslastadded"
            /// lowerCamelCase
            case albumsModified = "albumsmodified"
        }
    }
}
