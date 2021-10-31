//
//  GetItem.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: - Item

    /// Get the currently played item
    func getItem() async {
        let request = PlayerGetItem()
        
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)

            if item != result.item {
                logger("Player item changed")
                DispatchQueue.main.async {
                    self.item = result.item
                }
            }
        } catch {
            print("Loading player item failed with error: \(error)")
        }
    }

    /// Retrieves the currently played item (Kodi API)
    struct PlayerGetItem: KodiAPI {
        /// Method
        var method = Method.playerGetItem
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: GetItem())
        }
        /// The request struct
        struct GetItem: Encodable {
            let playerid = 0
            let properties = PlayerItem().properties
        }
        /// The response struct
        struct Response: Decodable {
            var item = PlayerItem()
        }
    }

    /// The struct for the player item
    struct PlayerItem: Decodable, Equatable {
        /// /// The properties that we ask from Kodi
        var properties = ["title", "artist", "mediapath"]
        /// The properties (and defaults)
        var songID: Int?
        var title: String?
        var artist: [String]?
        var mediapath: String = ""
        var type: String = ""
        enum CodingKeys: String, CodingKey {
            case title, artist, mediapath, type
            case songID = "id"
        }
    }
}
