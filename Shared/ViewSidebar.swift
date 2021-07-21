///
/// ViewSidebar.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewSidebar: View {
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            List {
                if appState.userInterface != .macOS {
                    ViewSearch()
                }
                ViewSmartLists()
                ViewTabsSidebar()
                switch appState.tabs.tabSidebar {
                case .genres:
                    ViewGenres()
                default:
                    ViewArtists()
                }
            }
            .onChange(of: KodiClient.shared.libraryJump) { item in
                proxy.scrollTo(item.artist, anchor: .center)
            }
        }
    }
}
