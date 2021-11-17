//
//  ViewSidebar.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The sidebar
struct ViewSidebar: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The setting to show the radio channels or not
    @AppStorage("showRadio") var showRadio: Bool = false
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            List {
                if appState.scanningLibrary {
                    HStack {
                        ProgressView()
                        /// Make this a bit smaller on macOS
                            .macOS {$0
                            .scaleEffect(0.5)
                            }
                        Text("Scanning the library")
                    }
                }
                if appState.state == .loadedLibrary {
                    libraryLists
                        .listRowInsets(EdgeInsets())
                    playlists
                        .listRowInsets(EdgeInsets())
                    if showRadio {
                        ViewRadio()
                            .listRowInsets(EdgeInsets())
                    }
                } else {
                    Section(header: ViewAppStateStatus()) {
                        EmptyView()
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .sidebarButtons()
        }
        .animation(.default, value: appState.sidebarItems)
    }
    /// View library lists
    var libraryLists: some View {
        Section(header: Text("Music on '\(KodiClient.shared.selectedHost.description)'")) {
            ForEach(appState.sidebarItems) { item in
                if item.visible {
                    sidebarButton(item: item)
                }
            }
        }
    }
    /// View playlists
    var playlists: some View {
        Section(header: Text("Playlists")) {
            ForEach(Library.shared.playlists.files) { item in
                sidebarButton(item: item)
            }
        }
    }
    /// A button in the sidebar
    func sidebarButton(item: Library.LibraryListItem) -> some View {
        Button(
            action: {
                Library.shared.selectLibraryList(libraryList: item)
            },
            label: {
                Label(item.title, systemImage: item.icon)
            }
        )
            .disabled(item.selected)
    }
}
