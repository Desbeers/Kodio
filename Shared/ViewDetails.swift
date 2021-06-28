///
/// ViewDetails.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewDetails (view)

/// A view that shown either songs or the playlist queue

struct ViewDetails: View {
    /// State of the tabs
    let tabs: AppState.TabOptions
    /// The view
    var body: some View {
        VStack {
            ViewKodiStatus()
            ViewTabSongsPlaylist()
                .padding(.vertical)
                .frame(width: 200)
            switch tabs {
            case .playlist:
                ViewPlaylist()
            default:
                ViewSongs()
            }
            ViewLog()
        }
        .background(Color("DetailsBackground"))
        .modifier(ToolbarModifier())
    }
}
