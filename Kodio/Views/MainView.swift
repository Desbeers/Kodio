//
//  ContentView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Main View vor Kodio
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
                    case .playlist(let file):
                        PlaylistView(playlist: file).id(appState.selection)
                    case .playingQueue:
                        QueueView()
                    case .musicVideos:
                        MusicVideosView(router: .all)
                    case .search:
                        BrowserView(router: .search, query: appState.query).id(appState.query)
                    case .musicMatch:
                        MusicMatchView()
                    default:
                        BrowserView(router: appState.selection ?? .library).id(appState.selection)
                    }
                }
                .modifier(ToolbarView())
            }
        )
        .animation(.default, value: appState.selection)
        .task(id: kodi.status) {
            if kodi.status != .loadedLibrary && appState.selection != .start {
                appState.selection = .start
            }
        }
    }
}
