//
//  PlayPause.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: sendPlayerPlayPause (No response needed)
    
    /// There are a few senario's
    /// - Playlist is paused: - > do play/pause
    /// - Playlist is playing: -> do play/pause
    /// - Playlist is stopped: -> do play playlist
    /// - Playlist is empty: - > disable button
    
    func sendPlayerPlayPause(queue: [Library.SongItem]) {
        if self.item.songID == nil && !queue.isEmpty {
            sendAction(method: .playerOpen, queueID: 0)
        } else {
            sendAction(method: .playerPlayPause)
        }
    }
}
