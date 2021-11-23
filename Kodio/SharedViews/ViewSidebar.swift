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
            .buttonStyle(ButtonStyleSidebar())
        }
        .animation(.default, value: appState.sidebarItems)
    }
}

extension ViewSidebar {
    
    /// View library lists
    var libraryLists: some View {
        Section(header: Text("Music on '\(appState.selectedHost.description)'")) {
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
        /// Define the color of the icon
        var iconColor: Color {
            switch item.media {
            case .playlist, .random, .neverPlayed:
                return Color.primary
            case .favorites:
                return Color.red
            default:
                /// - Note: On iOS, the accentColor for a disabled button is grey, so, force blue
                return appState.system == .macOS ? Color.accentColor : Color.blue
            }
        }
        /// Return the styled button
        return Button(
            action: {
                Task {
                    await Library.shared.selectLibraryList(libraryList: item)
                }
            },
            label: {
                /// - Note: Not in a ``Label`` because with multi-lines the icon does not center
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                    Text(item.title)
                        .lineLimit(nil)
                }
            }
        )
            .disabled(item.selected)
    }
}
