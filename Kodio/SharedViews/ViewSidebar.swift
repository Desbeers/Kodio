//
//  ViewSidebar.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The sidebar
struct ViewSidebar: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The Queue model
    @EnvironmentObject var queue: Queue
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            List {
                if appState.state == .loadedLibrary {
                    smartLists
                        .listRowInsets(EdgeInsets())
                    playlists
                        .listRowInsets(EdgeInsets())
                    ViewRadio()
                        .listRowInsets(EdgeInsets())
                } else {
                    Section(header: ViewAppStateStatus()) {
                        EmptyView()
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .sidebarButtons()
            Spacer()
        }
        .animation(.default, value: library.filter)
        .animation(.default, value: queue.songs)
    }
    /// View smart lists
    var smartLists: some View {
        Section(header: Text("Music on '\(KodiClient.shared.selectedHost.description)'")) {
            ForEach(library.getSmartLists()) { item in
                if item.visible {
                    sidebarButton(item: item)
                }
            }
        }
    }
    /// View playlists
    var playlists: some View {
        Section(header: Text("Playlists")) {
            ForEach(library.playlists.files) { item in
                sidebarButton(item: item)
            }
        }
    }
    /// A button in the sidebar
    func sidebarButton(item: Library.SmartListItem) -> some View {
        Button(
            action: {
                library.toggleSmartList(smartList: item)
            },
            label: {
                Label(item.title, systemImage: item.icon)
            }
        )
            .disabled(item.id == library.smartLists.selected.id)
            .animation(nil, value: library.filter)
    }
}
