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
    /// The Appstate model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            List {
                ViewSmartLists()
                    .listRowInsets(EdgeInsets())
                
                ViewPlaylist()
                    .listRowInsets(EdgeInsets())
                ViewRadio()
                    .listRowInsets(EdgeInsets())
            }
            .sidebarButtons()
        }
        .animation(.default, value: library.media)
        .transition(.move(edge: .leading))
    }
}
