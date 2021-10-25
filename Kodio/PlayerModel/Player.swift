//
//  Player.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// Player model
class Player: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this Player class
    static let shared = Player()
    /// The shared client class
    let kodiClient = KodiClient.shared
    /// The current item in the player
    @Published var item = PlayerItem()
    /// The properties of the player
    @Published var properties = Properties()
    /// Init the player class
    private init() {
//        /// Get the properties of the player
//        getProperties()
//        /// Get the current item loaded into the player
//        getItem()
    }
    /// The song title of the player item
    var title: String {
        var title = "Kodio"
        if let label = item.title, !label.isEmpty {
            title = label
        }
        return title
    }
    /// The artist name of the player item
    var artist: String {
        var title = "Play your own music"
        if let artist = item.artist?.first, !artist.isEmpty {
            title = artist
        }
        return title
    }
}

extension Player {
    
    // MARK: sendSongAndPlay (play one song from an album list)

    /// There are a few senario's
    /// - Song is already in the queue -> Jump to the song
    /// - It's a new song, open it in a new playlist

    func sendSongAndPlay(song: Library.SongItem) {
        let queue = Queue.shared.songs
        if let index = queue.firstIndex(where: { $0.songID == song.songID }) {
            /// Song is in the playlist, let's jump if the player is already playing
            if properties.speed == 1 {
                sendAction(method: .playerGoTo, queueID: queue[index].queueID)
            }
            /// Player is stopped; start at the playlist position
            else {
                sendAction(method: .playerOpen, queueID: queue[index].queueID)
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
        /// # Stop the player
        sendAction(method: .playerStop)
        /// # Clear the playlist
        queue.sendAction(method: .playlistClear)
        /// # Collect the songs to add
        var songList: [Int] = []
        for song in songs {
            songList.append(song.songID)
        }
        /// # Add the songs
        let request = Queue.QueueAction(method: .playlistAdd, songList: songList)
        
        Task {
            do {
                _ = try await KodiClient.shared.sendRequest(request: request)
                /// # Update the playlist queue
                await queue.getItems()
                /// # Start playing
                sendAction(method: .playerOpen, queueID: 0, shuffled: shuffled)
            } catch {
                print(error)
            }
        }
    }
}

extension Player {

    // MARK: getIcon (function)

    /// Get an icon for the row in a SwiftUI songlist
    /// - Parameter itemID: The ID of the song
    /// - Returns: A 'SF symbol' string that can be used for a SwiftUI image

    func getIcon(for song: Library.SongItem) -> String {
        /// Standard icon
        var icon = song.rating == 0 ? "music.note" : "heart"
        /// Overrule if needed
        if song.songID == self.item.songID {
            if self.properties.speed == 0 {
                icon = "pause.fill"
            } else {
                icon = "play.fill"
            }
        }
        return icon
    }
}
