//
//  LibraryActions.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Library actions
    
    /// Favorite a song or not
    /// - Parameter song: The ``SongItem``
    func favoriteSongToggle(song: SongItem) async {
        var favorite = song
        favorite.rating = favorite.rating == 0 ? 10 : 0
        await setSongDetails(song: favorite)
    }
    
    /// Reset a song
    /// - Parameter song: The ``SongItem``
    func resetSong(song: SongItem) async {
        var reset = song
        reset.playCount = 0
        reset.rating = 0
        reset.lastPlayed = "0000-00-00 00:00:00"
        await setSongDetails(song: reset)
    }
    
    /// Save the song details into the database
    /// - Parameter song: The ``SongItem``
    func setSongDetails(song: SongItem) async {
        let message = AudioLibrarySetSongDetails(song: song)
        kodiClient.sendMessage(message: message)
    }
}
