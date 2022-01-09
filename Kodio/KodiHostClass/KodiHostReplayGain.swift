//
//  KodiHostReplayGain.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: ReplayGain
    
    /// Set Kodi ReplainGain setting
    ///
    /// - When playing from a selected album; ReplayGain will be set to 'album' mode so the album is played as intended.
    /// - When playing random songs; ReplayGain will be set to 'track' so all songs are played at the same level.
    ///
    /// - Note: This wil alter the Kodi host settings and when quitting Kodio it will not be set back!
    /// 
    /// - Parameter mode: The ``ReplayGain`` mode to use
    func setReplayGain(mode: ReplayGain) async {
        logger("Set ReplayGain")
        let message = SettingsSetSettingValue(setting: .musicPlayerReplayGainType, value: mode.rawValue)
        kodiClient.sendMessage(message: message)
    }
    
    /// An ``enum`` with the modes of ReplayGain; track based or album based
    enum ReplayGain: Int {
        /// Use `album` mode
        case album = 1
        /// Use `track` mode
        case track = 2
    }
}
