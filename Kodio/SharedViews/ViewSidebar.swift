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
    @AppStorage("showRadio") var showRadio: Bool = true
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $appState.sidebarSelection) {
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
                    playlists
                    if showRadio {
                        ViewRadio()
                    }
                } else {
                    Section(header: ViewAppStateStatus()) {
                        EmptyView()
                    }
                }
            }
        }
        .animation(.default, value: appState.sidebarItems)
    }
}

extension ViewSidebar {
    
    /// An item in the sidebar
    @ViewBuilder func sidebarItem(item: Library.LibraryListItem) -> some View {
#if os(macOS)
        Label(item.title, systemImage: item.icon)
#endif
#if os(iOS)
        NavigationLink(destination: ViewLibrary().navigationBarTitleDisplayMode(.inline), tag: item, selection: $appState.sidebarSelection) {
            Label(item.title, systemImage: item.icon)
        }
#endif
    }
    
    /// View library lists
    var libraryLists: some View {
        Section(header: Text("Music on '\(appState.selectedHost.description)'")) {
            ForEach(appState.sidebarItems, id: \.self) { item in
                if item.visible {
                    sidebarItem(item: item)
                }
            }
        }
    }
    /// View playlists
    @ViewBuilder var playlists: some View {
        if !Library.shared.playlists.files.isEmpty {
            Section(header: Text("Playlists")) {
                ForEach(Library.shared.playlists.files, id: \.self) { item in
                    sidebarItem(item: item)
                }
            }
        }
    }
}
