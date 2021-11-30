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
            if result.items != queueItems {
                if !result.items.isEmpty {
                    /// Save the query for later
                    queueItems = result.items
                    logger("Queue has changed")
                    Task { @MainActor in
                        Player.shared.queueSongs = Library.shared.getSongsFromQueue()
                        /// Select 'Queue' in the sidebar again to reload it
                        if viewingQueue, let button = Library.shared.getLibraryLists().first(where: { $0.media == .queue}) {
                            await Library.shared.selectLibraryList(libraryList: button)
                        } else {
                            /// Update the sidebar to make sure we have a button
                            await AppState.shared.updateSidebar()
                        }
                    }
                } else {
                    logger("Queue is empty")
                    queueItems = []
                    Task { @MainActor in
                        Player.shared.queueSongs = []
                        /// Update the sidebar to make sure there is no queue button
                        await AppState.shared.updateSidebar()
                    }
                }
            }
        } catch {
            print(error)
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
