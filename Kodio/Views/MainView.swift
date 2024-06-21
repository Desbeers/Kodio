//
//  ContentView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the main view
struct MainView: View {
    /// The AppState model
    @Environment(AppState.self) private var appState
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// Show all columns
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    /// The body of the `View`
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                SidebarView()
            }, detail: {
                /// In a ZStack because the toolbar is added
                ZStack {
                    switch appState.selection {
                    case .start:
                        StartView()
                    case .appSettings:
                        NavigationStack {
                            SettingsView()
                        }
                    case .musicPlaylist(let file):
                        PlaylistView(playlist: file)
                            .id(appState.selection)
                    case .nowPlayingQueue:
                        QueueView()
                    case .musicVideos:
                        MusicVideosView()
                    case .search:
                        BrowserView()
                            .id(appState.query)
                    case .musicMatch:
                        MusicMatchView(kodi: kodi)
                    default:
                        BrowserView()
                            .id(appState.selection)
                    }
                }
                .modifier(ToolbarView())
            }
        )
        .task(id: kodi.status) {
            if kodi.status != .loadedLibrary && kodi.status != .updatingLibrary && appState.selection != .start {
                appState.selection = .start
            }
        }
    }
}
