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
    /// Search
    @StateObject var searchObserver = SearchFieldObserver.shared
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
        List {
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
            print("Jump to \(item.artist)")
            proxy.scrollTo(item.artist, anchor: .center)
        }
        }
    }
}
