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
    /// The search field in the toolbar
    @State var searchField: String = ""
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The body of the `View`
    var body: some View {
        List(selection: $appState.selection) {
            Label(title: {
                VStack(alignment: .leading) {
                    Text(kodi.host.bonjour?.name ?? "Kodio")
                    Text(kodi.status.message)
                        .font(.caption)
                        .opacity(0.5)
                }
            }, icon: {
                Image(systemName: "globe")
                    .foregroundColor(kodi.host.isOnline ? kodi.host.isSelected ? .green : .accentColor : .red)
            })
            .tag(Router.start)
            if kodi.status == .loadedLibrary {
                Section("Music") {
                    sidebarItem(item: Router.library)
                    sidebarItem(item: Router.recentlyAdded)
                    sidebarItem(item: Router.recentlyPlayed)
                    sidebarItem(item: Router.mostPlayed)
                    sidebarItem(item: Router.favorites)
                    if appState.settings.showMusicVideos {
                        sidebarItem(item: Router.musicVideos)
                    }
                }
                if appState.settings.showMusicMatch {
                    Section("Match") {
                        sidebarItem(item: Router.musicMatch)
                    }
                }
                Section("Queue") {
                    sidebarItem(item: Router.playingQueue)
                }
                if !searchField.isEmpty {
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
            }
        }
        .animation(.default, value: appState.query)
        .animation(.default, value: kodi.status)
        .searchable(text: $searchField, prompt: "Search library")
        .task(id: searchField) {
            await appState.updateSearch(query: searchField)
        }
    }

    /// Convert a ``Router`` iitem to a View
    /// - Parameter item: The ``Router`` item
    /// - Returns: A `View`
    func sidebarItem(item: Router) -> some View {
        Label(item.sidebar.title, systemImage: item.sidebar.icon)
            .tag(item)
    }
}
