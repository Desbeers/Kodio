//
//  AppState.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import Foundation
import SwiftlyKodiAPI

/// The class to observe the Kodio App state
@Observable
class AppState {
    /// The Kodio settings
    var settings: KodioSettings
    /// The current selection in the sidebar
    var selection: Router = .start
    /// The current search query
    var query: String = ""
    /// Init the class; get Kodio settings
    init() {
        self.settings = KodioSettings.load()
    }
}

extension AppState {

    /// Update the search query
    /// - Parameter query: The search query
    @MainActor
    func updateSearch(query: String) async {
        do {
            try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
            self.query = query
                if !query.isEmpty {
                    selection = .search
                } else if selection == .search {
                    /// Go to the main browser view; the search is canceled
                    selection = .musicBrowser
                }
        } catch { }
    }
}

extension AppState {

    /// Update the Kodio settings
    /// - Parameter settings: The ``KodioSettings``
    @MainActor
    func updateSettings(settings: KodioSettings) {
        KodioSettings.save(settings: settings)
        self.settings = settings
    }
}

extension AppState {

    /// Set the Player Settings if 'togglePlayerSettings' is true
    /// - Parameter media: The kind of media for optional crossfade
    func setPlayerSettings(host: HostItem, media: KodioSettings.Crossfade) {
        if settings.togglePlayerSettings {
            Task {
                /// Set defaults
                var replayGain: KodioSettings.ReplayGain = .track
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
                await Settings.setSettingValue(
                    host: host,
                    setting: .musicPlayerReplayGainType,
                    int: replayGain.rawValue
                )
                await Settings.setSettingValue(
                    host: host,
                    setting: .musicplayerCrossfadeAlbumTracks,
                    bool: crossfadeAlbumTracks
                )
                await Settings.setSettingValue(
                    host: host,
                    setting: .musicplayerCrossfade,
                    int: crossfade
                )
            }
        }
    }
}
