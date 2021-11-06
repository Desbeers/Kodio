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
            /// The player ID
            let playerid = 0
            /// The properties we ask for
            let properties = PlayerItem().properties
        }
        /// The response struct
        struct Response: Decodable {
            /// The item in the player
            var item = PlayerItem()
        }
    }

    /// The struct for the player item
    struct PlayerItem: Decodable, Equatable {
        /// The properties that we ask for
        var properties = ["title", "artist", "mediapath"]
        /// The ID of the song if the item is a song
        var songID: Int?
        /// The title of the item if the item is a song
        var title: String?
        /// The artist of the item if the item is a song
        var artist: [String]?
        /// The path of the item
        var mediapath: String = ""
        /// The type of the item
        var type: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case title, artist, mediapath, type
            /// ID is a reserved word
            case songID = "id"
        }
    }
}
