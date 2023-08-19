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
    @EnvironmentObject var appState: AppState
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
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
                        MusicVideosView(router: .musicVideos)
                    case .search:
                        BrowserView(router: .search, query: appState.query)
                            .id(appState.query)
#if os(macOS)
                    case .musicMatch:
                        MusicMatchView()
#endif
                    default:
                        BrowserView(router: appState.selection)
                            .id(appState.selection)
                    }
                }
                .modifier(ToolbarView())
            }
        )
        .animation(.default, value: appState.selection)
        .task(id: kodi.status) {
            if kodi.status != .loadedLibrary && kodi.status != .updatingLibrary && appState.selection != .start {
                appState.selection = .start
            }
        }
    }
}
