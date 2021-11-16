//
//  Properties.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: - Properties

    /// Get the properties of the player
    func getProperties() async {
        let request = PlayerGetProperties()
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
            if properties != result {
                Task { @MainActor in
                    logger("Player properties changed")
                    properties = result
                }
            }
        } catch {
            print("Loading player properties failed with error: \(error)")
        }
    }

    /// Retrieves the properties of the player (Kodi API)
    struct PlayerGetProperties: KodiAPI {
        /// Method
        var method = Method.playerGetProperties
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: GetProperties())
        }
        /// The request struct
        struct GetProperties: Encodable {
            /// The player ID
            let playerid = 0
            /// The properties we ask for
            let properties = ["speed", "position", "shuffled", "repeat", "percentage"]
        }
        /// The response struct
        typealias Response = Properties
    }

    /// The struct for the player properties
    struct Properties: Decodable, Equatable {
        /// The queue ID
        var queueID: Int = -1
        /// Repeat status
        var repeating: String = "off"
        /// Shuffle status
        var shuffled: Bool = false
        /// Speed of the player
        var speed: Int = 0
        /// Convert speed to a Bool
        var playing: Bool {
            return speed == 0 ? false : true
        }
        /// The icon to show for 'repeat'
        var repeatingIcon: String {
            /// Standard icon for 'repeat'
            var icon = "repeat"
            /// Overrule if needed
            if repeating == "one" {
                icon = "repeat.1"
            }
            return icon
        }
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case shuffled, speed
            /// A bit more logic word
            case queueID = "position"
            /// Repeat is a reserved word
            case repeating = "repeat"
        }
    }
}
