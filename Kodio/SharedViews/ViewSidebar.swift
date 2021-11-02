//
//  ViewSidebar.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The sidebar
struct ViewSidebar: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            List {
                if appState.state == .loadedLibrary {
                    ViewSmartLists()
                        .listRowInsets(EdgeInsets())
                    
                    ViewPlaylist()
                        .listRowInsets(EdgeInsets())
                    ViewRadio()
                        .listRowInsets(EdgeInsets())
                } else {
                    Section(header: ViewAppStateStatus()) {
                        EmptyView()
                    }
                }
            }
            .sidebarButtons()
        }
        .animation(.default, value: library.filter)
        .transition(.move(edge: .leading))
    }
}
