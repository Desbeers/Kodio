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
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack {
            ViewTabSongsPlaylist()
                .padding(.vertical)
                .frame(width: 200)
            ScrollViewReader { proxy in
                /// 'ScrollTo' is attached to a group because there are two list...
                Group {
                    if appState.tabs.tabSongPlaylist == .songs {
                        ViewSongs()
                    } else {
                        ViewPlaylist()
                    }
                }
                .onChange(of: kodi.libraryJump) { item in
                    DispatchQueue.main.async {
                        proxy.scrollTo(item.songID, anchor: .top)
                    }
                }
            }
        }
        .background(Color("DetailsBackground"))
    }
}
