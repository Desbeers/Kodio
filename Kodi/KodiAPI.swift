///
/// KodiAPI.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - KodiAPI (enum)

enum KodiAPI: String {
    
    /// Application
    case applicationGetProperties = "Application.GetProperties"
    case applicationQuit = "Application.Quit"
    
    /// Audio Library
    case audioLibraryScan = "AudioLibrary.Scan"
    case audioLibraryGetProperties = "AudioLibrary.GetProperties"
    case audioLibraryGetArtists = "AudioLibrary.GetArtists"
    case audioLibraryGetAlbums = "AudioLibrary.GetAlbums"
    case audioLibraryGetSongs = "AudioLibrary.GetSongs"
    case audioLibraryGetGenres = "AudioLibrary.GetGenres"

    /// Player
    case playerSetShuffle = "Player.SetShuffle"
    case playerSetRepeat = "Player.SetRepeat"
    case playerPlayPause = "Player.PlayPause"
    case playerOpen = "Player.Open"
    case playerStop = "Player.Stop"
    case playerGoTo = "Player.GoTo"
    case playerGetProperties = "Player.GetProperties"
    case playerGetItem = "Player.GetItem"

    /// Playlist
    case playlistClear = "Playlist.Clear"
    case playlistAdd = "Playlist.Add"
    case playlistRemove = "Playlist.Remove"
    case playlistSwap = "Playlist.Swap"
    case playlistGetItems = "Playlist.GetItems"

    /// Files
    case filesGetDirectory = "Files.GetDirectory"
}

extension KodiAPI {
    /// Nicer that using rawValue
    func method() -> String {
        return self.rawValue
    }
}
