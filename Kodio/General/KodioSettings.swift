//
//  KodioSettings.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/08/2022.
//

import Foundation
import SwiftlyKodiAPI

/// All the Kodio Settings
struct KodioSettings: Equatable, Codable {

    /// ### Sidebar

    /// Show Music Match
    var showMusicMatch = true
    /// Show Music Videos
    var showMusicVideos = true
    /// Show Radio Stations
    var showRadioStations = false

    /// ### Player

    /// Toggle Player Settings
    var togglePlayerSettings = false
}

extension KodioSettings {

    /// Load the Kodio settings
    /// - Returns: The ``KodioSettings``
    static func load() -> KodioSettings {
        logger("Get Kodio Settings")
        if let hosts = Cache.get(key: "KodioSettings", as: KodioSettings.self, root: true) {
            return hosts
        }
        /// No settings found
        return KodioSettings()
    }

    /// Save the Kodio settings to the cache
    /// - Parameter hosts: The array of hosts
    static func save(settings: KodioSettings) {
        do {
            try Cache.set(key: "KodioSettings", object: settings, root: true)
        } catch {
            logger("Error saving Kodio settings")
        }
    }
}

extension KodioSettings {

    /// Set the Player Settings if 'togglePlayerSettings' is true
    /// - Parameter setting: The ``ReplayGain`` setting
    static func setPlayerSettings(setting: ReplayGain) {
        if AppState.shared.settings.togglePlayerSettings {
            Task {
                await Settings.setSettingValue(setting: .musicPlayerReplayGainType, int: setting.rawValue)
                await Settings.setSettingValue(setting: .musicplayerCrossfadeAlbumTracks, bool: setting == .track ? true : false)
            }
        }
    }

    /// The modes of ReplayGain; track based or album based
    enum ReplayGain: Int {
        /// Use `album` mode
        case album = 1
        /// Use `track` mode
        case track = 2
    }
}
