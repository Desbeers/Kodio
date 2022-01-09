//
//  Player.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

/// The Player class
///
/// This class takes care of:
/// - Keeping an eye of the player state
/// - Send actions to the player on the host, like 'play', 'next', 'previous' etc.
final class Player: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this Player class
    static let shared = Player()
    /// The shared KodiClient class
    let kodiClient = KodiClient.shared
    /// The current item in the player
    @Published var item = PlayerItem()
    /// The properties of the player
    @Published var properties = Properties()
    /// The volume of the player
    @Published var volume: Double = 0
    /// Bool if the volume is muted or not
    @Published var muted: Bool = false
    /// Songs in the queue
    @Published var queueSongs: [Library.SongItem] = []
    /// Bool if the queue is empty
    /// - Note
    ///     - Used to disable the 'play/pause' button in the UI
    ///     - Look in the Queue class because there might be something else in the queue than songs
    var queueEmpty: Bool {
        return Queue.shared.queueItems.isEmpty ? true : false
    }
    /// Bool if the item in the queue is the first item
    /// - Note: Used to disable the 'play previous' button in the UI
    var queueFirst: Bool {
        return properties.queueID <= 0 || properties.partymode ? true : false
    }
    /// Bool if the item in the queue is the last item
    /// - Note:
    ///     - Used to disable the 'play next' button in the UI
    ///     - Kodi counts from zero, so one less from the `queueItems` count
    var queueLast: Bool {
        return (queueEmpty || properties.queueID == -1 || properties.queueID == Queue.shared.queueItems.count - 1) ? true : false
    }
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {}
}
