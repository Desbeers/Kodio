///
/// ViewSidebar.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewSidebar: View {
    /// State of the tabs
    let tabs: AppState.TabOptions
    /// The view
    var body: some View {
            VStack(spacing: 0) {
                ViewSmartLists()
                switch tabs {
                case .genres:
                    ViewGenres()
                default:
                    ViewArtists()
                }
            }
    }
}
