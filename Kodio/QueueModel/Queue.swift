//
//  LibraryQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// Queue Model
class Queue: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = Queue()
    /// The shared client class
    let kodiClient = KodiClient.shared
    /// Song ID's in queue
    var queueItems: [QueueItem] = []
    /// Count of items in the queue
    var items: Int {
        /// Kodi counts from zero
        return queueItems.count - 1
    }
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {}
}
