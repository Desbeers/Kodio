///
/// ViewSidebar.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewSidebar: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            Group {
                ViewSmartLists()
                    .padding(.horizontal)
                ViewTabArtistsGenres()
                if appState.tabs.tabArtistGenre == .artists {
                    ViewArtists()
                } else {
                    ViewGenres()
                }
            }
            .onChange(of: kodi.libraryJump) { item in
                proxy.scrollTo(item.artistID, anchor: .center)
            }
        }
    }
}
