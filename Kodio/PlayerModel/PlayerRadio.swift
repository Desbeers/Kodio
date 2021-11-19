//
//  PlayerRadio.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: Radio stations (extension)

    /// Play a radio station
    /// - Parameter stream: the audio stream to play
    func playRadio(stream: String) {
        let request = Queue.QueueAction(method: .playlistAdd, stream: stream)
        Task {
            do {
                Queue.shared.sendAction(method: .playlistClear)
                _ = try await kodiClient.sendRequest(request: request)
                /// # Start playing
                Player.shared.sendAction(method: .playerOpen, queueID: 0)
            } catch {
                print(error)
            }
        }
    }
}
