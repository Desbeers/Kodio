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
            let result = try await kodiClient.sendRequest(request: request)
            /// Only update the item when it is changed
            if item != result.item {
                Task { @MainActor in
                    logger("Player item changed")
                    item = result.item
                }
            }
            /// Keep an eye on the player if it is not a song
            if item.songID == nil {
                Task {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    await Player.shared.getItem()
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
    struct PlayerItem: Decodable, Equatable, Hashable {
        /// The properties that we ask for
        var properties = ["title", "artist", "mediapath"]
        /// The ID of the song if the item is a song
        var songID: Int?
        /// The title of the item
        var title: String?
        /// The main title to display
        var maintitle: String {
            return title ?? ""
        }
        /// The subtitle of the item
        var subtitle: String {
            return artist?.joined(separator: " & ") ?? ""
        }
        /// The artist of the item
        var artist: [String]?
        /// The path of the item
        var mediaPath: String?
        /// The type of the item
        var type: String?
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case title, artist, type
            /// lowerCamelCase
            case mediaPath = "mediapath"
            /// ID is a reserved word
            case songID = "id"
        }
    }
}
