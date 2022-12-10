//
//  SidebarView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Sidebar View
struct SidebarView: View {
    /// The SceneState model
    @EnvironmentObject var scene: SceneState
    /// The search query
    @Binding var query: String
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The body of the `View`
    var body: some View {
        List(selection: $scene.selection) {
            Section(appState.host?.details.description ?? "Not connected") {
                sidebarItem(item: Router.library)
                sidebarItem(item: Router.recentlyAdded)
                sidebarItem(item: Router.recentlyPlayed)
                sidebarItem(item: Router.mostPlayed)
                sidebarItem(item: Router.favorites)
                sidebarItem(item: Router.musicVideos)
            }
#if os(macOS)
            if appState.settings.showMusicMatch {
                Section("Match") {
                    sidebarItem(item: Router.musicMatch)
                }
            }
#endif
            Section("Queue") {
                sidebarItem(item: Router.playingQueue)
            }
            if !query.isEmpty {
                Section("Search") {
                    sidebarItem(item: Router.search)
                }
            }
            if !kodi.library.audioPlaylists.isEmpty {
                Section("Playlists") {
                    ForEach(kodi.library.audioPlaylists, id: \.self) { playlist in
                        sidebarItem(item: Router.playlist(file: playlist))
                    }
                }
            }
            if appState.settings.showRadioStations {
                Section("Radio Stations") {
                    ForEach(radioStations, id: \.self) { channel in
                        ButtonStyles.RadioStation(channel: channel)
                    }
                }
                .buttonStyle(.plain)
            }
            /// Make space for the status view
            Spacer(minLength: 40)
        }
        .animation(.default, value: query)
        .animation(.default, value: appState.settings)
    }

    /// Convert a ``Router`` iitem to a View
    /// - Parameter item: The ``Router`` item
    /// - Returns: A `View`
    @ViewBuilder func sidebarItem(item: Router) -> some View {
        if appState.visible(route: item) {
            Label(item.sidebar.title, systemImage: item.sidebar.icon)
                .tag(item)
        }
    }
}
