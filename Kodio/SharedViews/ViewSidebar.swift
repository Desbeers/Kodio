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
                    libraryLists
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
        .animation(.default, value: library.selection.id)
        .animation(.default, value: queue.songs)
    }
    /// View library lists
    var libraryLists: some View {
        Section(header: Text("Music on '\(KodiClient.shared.selectedHost.description)'")) {
            ForEach(library.getLibraryLists()) { item in
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
    func sidebarButton(item: Library.LibraryListItem) -> some View {
        Button(
            action: {
                library.selectLibraryList(libraryList: item)
            },
            label: {
                Label(item.title, systemImage: item.icon)
            }
        )
            .disabled(item.id == library.libraryLists.selected.id)
            .animation(nil, value: library.libraryLists.selected)
    }
}
