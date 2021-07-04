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
    /// Search
    @StateObject var searchObserver = SearchFieldObserver.shared
    /// The view
    var body: some View {
        HStack {
            ViewAlbums()
            
            VStack {
                ViewKodiStatus()
                ViewTabsDetails()
                    .padding(.horizontal)
                    .padding()
                if appState.userInterface != .macOS {
                    SearchField(search: $searchObserver.searchText)
                        .frame(minWidth: 100, idealWidth: 150, maxWidth: 200)
                }
                switch appState.tabs.tabDetails {
                case .playlists:
                    ViewPlaylists()
                case .radio:
                    ViewRadioStations()
                case .playqueue:
                    ViewPlaylistQueue()
                default:
                    ViewSongs()
                }
                ViewLog()
            }
        }
        .background(Color("DetailsBackground"))
        .modifier(ToolbarModifier())
        .modifier(DetailsModifier())
    }
}
