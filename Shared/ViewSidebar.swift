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
            VStack(spacing: 0) {
                ViewSmartLists()
                switch appState.tabs.tabArtistGenre {
                case .genres:
                    ViewGenres()
                default:
                    ViewArtists()
                }
            }
    }
}
