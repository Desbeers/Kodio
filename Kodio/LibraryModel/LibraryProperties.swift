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
                status.upToDate = true
            } else {
                if let cache = Cache.get(key: "LibraryLastUpdated", as: Properties.self),
                   cache.libraryLastUpdated < result.libraryLastUpdated {
                    status.upToDate = false
                    logger("Library is out of date.")
                    let appState: AppState = .shared
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        appState.alert = appState.alertOutdatedLibrary
                    }
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
            let properties = ["librarylastupdated"]
        }
        /// The response struct
        typealias Response = Properties
    }

    /// The struct for the library properties
    struct Properties: Codable {
        /// Last update
        var libraryLastUpdated: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// lowerCamelCase
            case libraryLastUpdated = "librarylastupdated"
        }
    }
}
