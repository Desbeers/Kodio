//
//  PlayerRadio.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import Foundation

// MARK: - Radio stations (extension)

extension Player {
    
    // MARK: Play a Radio Station

    /// Play a radio station
    /// - Parameter stream: the audio stream to play
    func playRadio(stream: String) {
        /// # Don't bother with notifications
        // self.notificate = false
        /// # Clear the playlist
        Queue.shared.sendAction(method: .playlistClear)
        /// # Add the stream and play it
        let request = Queue.QueueAction(method: .playlistAdd, stream: stream)
        
        Task {
            do {
                _ = try await KodiClient.shared.sendRequest(request: request)
                /// # Start playing
                Player.shared.sendAction(method: .playerOpen, queueID: 0)
                /// # Empty the playlist queue
                Queue.shared.songs = []
                DispatchQueue.main.async {
                    Queue.shared.objectWillChange.send()
                }
            } catch {
                print(error)
            }
        }
    }
}
