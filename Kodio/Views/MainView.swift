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
    /// The search field in the toolbar
    @State var searchField: String = ""
    /// Show all columns
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    /// The body of the `View`
    var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: {
                ZStack {
                    SidebarView(query: $appState.query)
                    StatusView()
                        .animation(.default, value: kodi.status)
                }
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
            })
        .background(Color("Window"))
        .searchable(text: $searchField, prompt: "Search library")
        .task(id: searchField) {
            await appState.updateSearch(query: searchField)
        }
    }
}
