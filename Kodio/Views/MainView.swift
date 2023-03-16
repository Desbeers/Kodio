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
    /// The SceneState model
    @StateObject var scene = SceneState()
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
                    SidebarView(query: $scene.query)
                    StatusView()
                        .animation(.default, value: kodi.status)
                }
            }, detail: {
                /// In a ZStack because the toolbar is added
                ZStack {
                    switch scene.selection {
                    case .start:
                        StartView()
                    case .playlist(let file):
                        PlaylistView(playlist: file).id(scene.selection)
                    case .playingQueue:
                        QueueView()
                    case .musicVideos:
                        MusicVideosView(router: .all)
                    case .search:
                        BrowserView(router: .search, query: scene.query).id(scene.query)
                    case .musicMatch:
                        MusicMatchView()
                    default:
                        BrowserView(router: scene.selection ?? .library).id(scene.selection)
                    }
                }
                .modifier(ToolbarView())
            })
        .background(Color("Window"))
        .environmentObject(scene)
        .searchable(text: $searchField, prompt: "Search library")
        .task(id: searchField) {
            await scene.updateSearch(query: searchField)
        }
    }
}
