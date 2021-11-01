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
        let request = QueueGetItems()
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
            if result.items != queueItems {
                DispatchQueue.main.async {
                    logger("Queue has changed")
                    /// Save the query for later
                    self.queueItems = result.items
                    /// Find the songs in the database
                    var songList: [Library.SongItem] = []
                    let allSongs = Library.shared.songs.all
                    for (index, song) in result.items.enumerated() {
                        if var item = allSongs.first(where: { $0.songID == song.songID }) {
                            item.queueID = index
                            songList.append(item)
                        }
                    }
                    self.songs = songList
                }
            }
//
//            print(result.items)
//
//            DispatchQueue.main.async {
//                var songList: [Library.SongItem] = []
//                let allSongs = Library.shared.songs.all
//                for (index, song) in result.items.enumerated() {
//                    if var item = allSongs.first(where: { $0.songID == song.songID }) {
//                        item.queueID = index
//                        songList.append(item)
//                    }
//                }
//                if songList != self.songs {
//                    logger("Queue has changed")
//                    self.songs = songList
//                }
//            }
            Library.shared.status.queue = true
        } catch {
            Library.shared.status.queue = false
            DispatchQueue.main.async {
                self.songs = []
            }
        }
    }
    
    /// Get all items from playlist (Kodi API)
    struct QueueGetItems: KodiAPI {
        var method: Method = .playlistGetItems
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            let playlistid = 0
        }
        /// The response struct
        struct Response: Decodable {
            let items: [QueueItem]
        }
    }
    
    /// The struct for a queue item
    struct QueueItem: Codable, Equatable {
        let songID: Int
        enum CodingKeys: String, CodingKey {
            case songID = "id"
        }
    }
}
