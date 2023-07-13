//
//  SidebarView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the sidebar
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
            Label(
                title: {
                    VStack(alignment: .leading) {
                        Text(kodi.host.bonjour?.name ?? "Kodio")
                        Text(kodi.status.message)
                            .font(.caption)
                            .opacity(0.5)
                    }
                }, icon: {
                    Image(systemName: "globe")
                }
            )
            .listItemTint(kodi.host.isOnline ? .green : .red)
            .tag(Router.start)
            if kodi.status == .loadedLibrary {
                sidebarItem(router: .favourites)
                Section("Music") {
                    sidebarItem(router: .musicBrowser)
                    sidebarItem(router: .compilationAlbums)
                    sidebarItem(router: .recentlyAddedMusic)
                    sidebarItem(router: .recentlyPlayedMusic)
                    sidebarItem(router: .mostPlayedMusic)
                    if appState.settings.showMusicVideos {
                        sidebarItem(router: .musicVideos)
                    }
                }
                if appState.settings.showMusicMatch {
                    Section("Match") {
                        sidebarItem(router: .musicMatch)
                    }
                }
                Section("Queue") {
                    sidebarItem(router: .nowPlayingQueue)
                }
                if !searchField.isEmpty {
                    Section("Search") {
                        sidebarItem(router: .search)
                    }
                }
                if !kodi.library.audioPlaylists.isEmpty {
                    Section("Playlists") {
                        ForEach(kodi.library.audioPlaylists, id: \.self) { playlist in
                            sidebarItem(router: .musicPlaylist(file: playlist))
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
        .searchable(text: $searchField, prompt: "Search library")
        .task(id: searchField) {
            await appState.updateSearch(query: searchField)
        }
    }

    /// SwiftUI `View` for an item in the sidebar
    /// - Parameter router: The ``Router`` item
    /// - Returns: A SwiftUI `View` with the sidebar item
    private func sidebarItem(router: Router) -> some View {
        Label(router.item.title, systemImage: router.item.icon)
            .tag(router)
            .listItemTint(router.item.color)
    }
}
