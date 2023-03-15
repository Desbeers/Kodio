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
    /// Crossfade playlists
    var crossfadePlaylists = false
    /// Crossfade compilation albums
    var crossfadeCompilations = false
    /// Crossfade Party Mode
    var crossfadePartyMode = false
    /// Crossfade duration (when enabled)
    var crossfade: Int = 3
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
    /// - Parameter media: The kind of media for optional  ``Crossfade``
    static func setPlayerSettings(media: Crossfade) {
        let settings = AppState.shared.settings
        if settings.togglePlayerSettings {
            Task {
                /// Set defaults
                var replayGain: ReplayGain = .track
                var crossfade: Int = settings.crossfade
                var crossfadeAlbumTracks: Bool = true
                /// Alter defaults if needed
                switch media {
                case .album:
                    replayGain = .album
                    /// Never crossfade a full album
                    crossfadeAlbumTracks = false
                    crossfade = 0
                case .playlist:
                    crossfade = settings.crossfadePlaylists ? crossfade : 0
                case .compilation:
                    crossfade = settings.crossfadeCompilations ? crossfade : 0
                case .partymode:
                    crossfade = settings.crossfadePartyMode ? crossfade : 0
                }
                /// Apply the settings
                await Settings.setSettingValue(setting: .musicPlayerReplayGainType, int: replayGain.rawValue)
                await Settings.setSettingValue(setting: .musicplayerCrossfadeAlbumTracks, bool: crossfadeAlbumTracks)
                await Settings.setSettingValue(setting: .musicplayerCrossfade, int: crossfade)
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

    /// The media for optional Crossfade
    enum Crossfade {
        case album
        case playlist
        case compilation
        case partymode
    }
}
