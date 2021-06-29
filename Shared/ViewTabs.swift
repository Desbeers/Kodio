///
/// ViewTabs.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewTabsSidebar (view)

/// Tab between artists and genres
struct ViewTabsSidebar: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        Picker("Playlist", selection: $appState.tabs.tabArtistGenre) {
            Text("Artists").tag(AppState.TabOptions.artists)
            Text("Genres").tag(AppState.TabOptions.genres)
        }
        .pickerStyle(SegmentedPickerStyle())
        .labelsHidden()
        .padding()
    }
}

// MARK: - ViewTabsDetails (view)

struct ViewTabsDetails: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        Picker("Playlist", selection: $appState.tabs.tabSongPlaylist) {
            Text("My songs").tag(AppState.TabOptions.songs)
            Text("My playlists").tag(AppState.TabOptions.playlists)
            Text("Play queue").tag(AppState.TabOptions.playqueue)
        }
        .pickerStyle(SegmentedPickerStyle())
        .labelsHidden()
    }
}
