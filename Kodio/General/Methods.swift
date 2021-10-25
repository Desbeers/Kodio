///
/// KodiAPI.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - Method (enum)

/// Kodi methods used by KodiAPI
enum Method: String {
    
    /// Kodi host
    case applicationGetProperties = "Application.GetProperties"
    case applicationQuit = "Application.Quit"
    case applicationSetVolume = "Application.SetVolume"
    /// Notifications
    case applicationOnVolumeChanged = "Application.OnVolumeChanged"

    /// Settings
    case settingsSetSettingvalue = "Settings.SetSettingvalue"
    
    /// Audio Library
    case audioLibraryScan = "AudioLibrary.Scan"
    case audioLibraryGetProperties = "AudioLibrary.GetProperties"
    case audioLibraryGetArtists = "AudioLibrary.GetArtists"
    case audioLibraryGetAlbums = "AudioLibrary.GetAlbums"
    case audioLibraryGetSongs = "AudioLibrary.GetSongs"
    case audioLibrarySetSongDetails = "AudioLibrary.SetSongDetails"
    case audioLibraryGetGenres = "AudioLibrary.GetGenres"
    
    /// Notifications
    case audioLibraryOnUpdate = "AudioLibrary.OnUpdate"
    case audioLibraryOnScanStarted = "AudioLibrary.OnScanStarted"
    case audioLibraryOnScanFinished = "AudioLibrary.OnScanFinished"

    /// Player
    case playerSetShuffle = "Player.SetShuffle"
    case playerSetRepeat = "Player.SetRepeat"
    case playerPlayPause = "Player.PlayPause"
    case playerOpen = "Player.Open"
    case playerStop = "Player.Stop"
    case playerGoTo = "Player.GoTo"
    case playerGetProperties = "Player.GetProperties"
    case playerGetItem = "Player.GetItem"
    case playerOnSpeedChanged = "Player.OnSpeedChanged"
    
    /// Notifications
    case playerOnPlay = "Player.OnPlay"
    case playerOnStop = "Player.OnStop"
    case playerOnPropertyChanged = "Player.OnPropertyChanged"
    case playerOnResume = "Player.OnResume"
    case playerOnPause = "Player.OnPause"
    case playerOnAVStart = "Player.OnAVStart"

    /// Playlist
    case playlistClear = "Playlist.Clear"
    case playlistAdd = "Playlist.Add"
    case playlistRemove = "Playlist.Remove"
    case playlistSwap = "Playlist.Swap"
    case playlistGetItems = "Playlist.GetItems"
    /// Notifications
    case playlistOnClear = "Playlist.OnClear"

    /// Files
    case filesGetDirectory = "Files.GetDirectory"
}
