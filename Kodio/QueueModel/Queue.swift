//
//  LibraryQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

class Queue: ObservableObject {
    
    // MARK: - Queue
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = Queue()
    /// The shared client class
    let kodiClient = KodiClient.shared
    /// Songs in the queue
    @Published var songs: [Library.SongItem] = []
    /// Count of items in the queue
    var items: Int {
        /// Kodi counts from zero
        return songs.count - 1
    }
    private init() {}
}
