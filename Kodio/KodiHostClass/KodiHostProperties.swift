//
//  Properties.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: Properties
    
    /// Get the properties of the Kodi host
    func getProperties() async {
        let request = ApplicationGetProperties()
        do {
            let result = try await kodiClient.sendRequest(request: request)
            if properties != result {
                logger("Host properties changed")
                properties = result
                Task { @MainActor in
                    /// - Note: Stuff it in the Player class because that is observed for the volume slider in the UI
                    Player.shared.volume = result.volume
                    Player.shared.muted = result.muted
                }
            }
        } catch {
            print("Loading Kodi properties failed with error: \(error)")
        }
    }
    
    /// Retrieves the Kodi host properties (Kodi API)
    struct ApplicationGetProperties: KodiAPI {
        /// Method
        var method = Method.applicationGetProperties
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// The requested properties
            let properties = [
                "volume",
                "muted",
                "name",
                "version",
                "sorttokens",
                "language"
            ]
        }
        /// The response struct
        typealias Response = Properties
    }
    
    /// The struct for the Kodi properties
    struct Properties: Codable, Equatable {
        /// Name of the Kodi host
        var name: String = ""
        /// Volume settig of the Kodi host
        var volume: Double = 0
        /// Bool if the sound is muted or not
        var muted: Bool = false
        /// Kodi host version
        var version = Version()
        /// The version struct (major and minor number)
        struct Version: Codable, Equatable {
            /// Major version number
            var major: Int = 0
            /// Minor version number
            var minor: Int = 0
        }
        /// The coding keys for the Kodi properties
        enum CodingKeys: String, CodingKey {
            /// The cases
            case name, version, volume, muted
        }
    }
}
