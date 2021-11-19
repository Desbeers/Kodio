//
//  QueueGetItems.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Queue {
    
    // MARK: - Items
    
    /// Get a lists of songs in the queue
    func getItems() async {
        let viewingQueue: Bool = Library.shared.libraryLists.selected.media == .queue ? true : false
        let request = QueueGetItems()
        do {
            let result = try await kodiClient.sendRequest(request: request)
            if result.items != Player.shared.queueItems {
                if result.items.first?.songID != nil {
                    /// Save the query for later
                    logger("Queue has changed")
                    Player.shared.queueItems = result.items
                } else {
                    logger("Queue is empty")
                    Player.shared.queueItems = []
                }
            }
        } catch {
            print(error)
        }
        /// Update view or sidebar
        if viewingQueue {
            let library: Library = .shared
            if Player.shared.queueItems.isEmpty {
                logger("Select first item in the sidebar")
                library.selectLibraryList(libraryList: library.libraryLists.all.first!)
            } else {
                logger("Reload queue view")
                library.selectLibraryList(libraryList: library.libraryLists.selected)
            }
        } else {
            Task { @MainActor in
                   AppState.shared.updateSidebar()
            }
        }
    }
    
    /// Get all items from playlist (Kodi API)
    struct QueueGetItems: KodiAPI {
        /// The method to use
        let method: Method = .playlistGetItems
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// The playlist ID
            let playlistid = 0
        }
        /// The response struct
        struct Response: Decodable {
            /// The items in the queue
            let items: [QueueItem]
        }
    }
    
    /// The struct for a queue item
    struct QueueItem: Codable, Equatable {
        /// The song ID
        let songID: Int?
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// ID is a reserved word
            case songID = "id"
        }
    }
}
