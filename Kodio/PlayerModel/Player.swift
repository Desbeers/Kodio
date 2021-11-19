//
//  Player.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// Player model
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
    /// Song ID's in the queue
    @Published var queueItems: [Queue.QueueItem] = []
    /// Count of items in the queue
    var items: Int {
        /// Kodi counts from zero
        return queueItems.count - 1
    }
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {}
}

extension Player {
    
    // MARK: sendSongAndPlay (play one song from an album list)

    /// There are a few senario's
    /// - Song is already in the queue -> Jump to the song
    /// - It's a new song, open it in a new playlist

    func sendSongAndPlay(song: Library.SongItem) {
        let queueSongs = Library.shared.getSongsFromQueue()
        if let index = queueSongs.firstIndex(where: { $0.songID == song.songID }) {
            /// Song is in the playlist, let's jump if the player is already playing
            if properties.speed == 1 {
                sendAction(method: .playerGoTo, queueID: queueSongs[index].queueID)
            }
            /// Player is stopped; start at the playlist position
            else {
                sendAction(method: .playerOpen, queueID: queueSongs[index].queueID)
            }
        }
        /// Song is not in the playlist; just open it in a new playlist
        else {
            sendSongsAndPlay(songs: [song])
        }
    }
}

extension Player {
    
    // MARK: - sendSongsAndPlay

    /// - Stop the player
    /// - Clear the playlist
    /// - Fill the playlist with songs
    /// - Start the player
    /// - Update the playlist viewer
    func sendSongsAndPlay(songs: [Library.SongItem], shuffled: Bool = false) {
        /// Get the shared Queue class
        let queue = Queue.shared
        /// Clear the playlist
        queue.sendAction(method: .playlistClear)
        /// Collect the songs to add
        var songList: [Int] = []
        for song in songs {
            songList.append(song.songID)
        }
        /// Add the songs
        let request = Queue.QueueAction(method: .playlistAdd, songList: songList)
        
        Task {
            do {
                _ = try await kodiClient.sendRequest(request: request)
                /// Start playing
                sendAction(method: .playerOpen, queueID: 0, shuffled: shuffled)
            } catch {
                print(error)
            }
        }
    }
}
