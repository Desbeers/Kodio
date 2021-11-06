//
//  ViewSettings.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the Kodio settings
struct ViewSettings: View {
    /// The view
    var body: some View {
        #if os (macOS)
        TabView {
            ViewHostsEdit()
            .tabItem {
                Label("Hosts", systemImage: "list.dash")
            }
        }
        #endif
        #if os (iOS)
        ViewHostsEdit()
        #endif
    }
}
