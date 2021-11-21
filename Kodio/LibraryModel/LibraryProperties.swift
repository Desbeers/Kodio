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
            let result = try await kodiClient.sendRequest(request: request)
            /// Save if cache is true
            if cache {
                try Cache.set(key: "LibraryLastUpdated", object: result)
            } else {
                if let lastUpdate = Cache.get(key: "LibraryLastUpdated", as: Properties.self),
                   lastUpdate.songsLastAdded == result.songsLastAdded,
                   lastUpdate.albumsModified == result.albumsModified,
                   lastUpdate.albumsLastAdded == result.albumsLastAdded {
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
            let properties = [
                "songslastadded",
                "songsmodified",
                "albumslastadded",
                "albumsmodified",
                "librarylastcleaned",
                "librarylastupdated"
            ]
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
        /// Last cleaning of library
        var libraryLastCleaned: String = ""
        /// Last library scan
        /// - Note: That's *not* the last actual update; a bit misleading
        var libraryLastUpdated: String = ""
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
            /// lowerCamelCase
            case libraryLastCleaned = "librarylastcleaned"
            /// lowerCamelCase
            case libraryLastUpdated = "librarylastupdated"
        }
    }
}
