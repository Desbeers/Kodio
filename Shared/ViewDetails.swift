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
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack {
            ViewKodiStatus()
            ViewTabSongsPlaylist()
                .padding(.vertical)
                .frame(width: 200)
            switch appState.tabs.tabSongPlaylist {
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
