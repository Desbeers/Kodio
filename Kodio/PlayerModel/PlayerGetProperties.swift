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
                logger("Player properties changed")
                DispatchQueue.main.async {
                    self.properties = result
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
            let playerid = 0
            let properties = ["speed", "position", "shuffled", "repeat", "percentage"]
        }
        /// The response struct
        typealias Response = Properties
    }

    /// The struct for the player properties
    struct Properties: Decodable, Equatable {
        var queueID: Int = -1
        var repeating: String = ""
        var shuffled: Bool = false
        var speed: Int = 0
        var playing: Bool {
            return speed == 0 ? false : true
        }
        var repeatingIcon: String {
            /// Standard icon
            var icon = "repeat"
            /// Overrule if needed
            if repeating == "one" {
                icon = "repeat.1"
            }
            return icon
        }
        enum CodingKeys: String, CodingKey {
            case shuffled, speed
            case queueID = "position"
            case repeating = "repeat"
        }
    }
}
